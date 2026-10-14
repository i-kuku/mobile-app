import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

import '../helpers/fake_supabase.dart';

const batchesPath = '/rest/v1/batches';

Map<String, dynamic> batchRow(
  String id, {
  String name = 'Batch',
  String createdAt = '2025-03-01T00:00:00.000Z',
}) => {
  'id': id,
  'user_id': fakeUserId,
  'name': name,
  'type_of_bird': 'Layers',
  'initial_count': 100,
  'age': 2,
  'age_unit': 'weeks',
  'created_at': createdAt,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final backend = FakeSupabaseBackend();
  late SyncEngine sync;

  setUpAll(() => initFakeSupabase(backend));

  setUp(() async {
    backend.reset();
    sync = (await initOfflineServices()).sync;
  });

  tearDown(() async {
    await resetOfflineServices();
    await signOutFakeUser();
  });

  Future<void> addLayers(BatchProvider provider) => provider.addBatch(
    name: 'Broilers A',
    typeOfBird: 'Broilers',
    initialCount: 50,
    age: 3,
    ageUnit: 'days',
    purchaseCost: 0,
  );

  group('signed out', () {
    test('fetchBatches does not query the server', () async {
      final provider = BatchProvider();
      await provider.fetchBatches();
      expect(provider.batches, isEmpty);
      expect(backend.requestsTo(batchesPath), isEmpty);
    });

    test('addBatch throws and saves nothing', () async {
      await expectLater(
        addLayers(BatchProvider()),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authenticated'),
          ),
        ),
      );
      expect(sync.pendingCount, 0);
      expect(sync.store.rows(LocalTables.batches), isEmpty);
    });
  });

  group('signed in', () {
    late BatchProvider provider;
    late int notifications;

    setUp(() async {
      await signInFakeUser(backend);
      provider = BatchProvider();
      notifications = 0;
      provider.addListener(() => notifications++);
    });

    tearDown(() => provider.dispose());

    test('fetchBatches loads the user\'s batches newest first', () async {
      backend.on(
        'GET',
        batchesPath,
        (_) async => FakeSupabaseBackend.json([
          batchRow('b1', createdAt: '2025-01-01T00:00:00Z'),
          batchRow('b2', createdAt: '2025-02-01T00:00:00Z'),
        ]),
      );

      await provider.fetchBatches();

      expect(provider.batches.map((b) => b.id), ['b2', 'b1']);
      final query = backend.requestsTo(batchesPath).single.url.queryParameters;
      expect(query['user_id'], 'eq.$fakeUserId');
      expect(notifications, greaterThan(0));
    });

    test('fetchBatches shows what is on the device straight away', () async {
      await sync.store.put(LocalTables.batches, batchRow('saved'));
      backend.on('GET', '/rest/v1/users', unreachable);

      await provider.fetchBatches();

      expect(provider.batches.map((b) => b.id), ['saved']);
    });

    test('fetchBatches replaces previously loaded batches', () async {
      backend.on(
        'GET',
        batchesPath,
        (_) async => FakeSupabaseBackend.json([batchRow('old')]),
      );
      await provider.fetchBatches();
      backend.on(
        'GET',
        batchesPath,
        (_) async => FakeSupabaseBackend.json([batchRow('new')]),
      );
      await sync.refresh(force: true);

      expect(provider.batches.map((b) => b.id), ['new']);
    });

    test(
      'fetchBatches keeps existing batches when the server errors',
      () async {
        backend.on(
          'GET',
          batchesPath,
          (_) async => FakeSupabaseBackend.json([batchRow('b1')]),
        );
        await provider.fetchBatches();
        backend.on(
          'GET',
          batchesPath,
          (_) async =>
              FakeSupabaseBackend.json({'message': 'boom'}, status: 500),
        );

        await sync.refresh(force: true);

        expect(provider.batches.map((b) => b.id), ['b1']);
      },
    );

    test('addBatch shows the batch at once, then upserts it', () async {
      backend.on('POST', batchesPath, (_) async => http.Response('', 201));

      await addLayers(provider);

      final batch = provider.batches.single;
      expect(batch.name, 'Broilers A');
      expect(backend.requests, isEmpty);

      await sync.sync(pull: false);

      final insert = backend.requestsTo(batchesPath, method: 'POST').single;
      expect(jsonDecode(insert.body), {
        'id': batch.id,
        'user_id': fakeUserId,
        'name': 'Broilers A',
        'type_of_bird': 'Broilers',
        'initial_count': 50,
        'age': 3,
        'age_unit': 'days',
        'purchase_cost': 0,
        'created_at': batch.createdAt.toUtc().toIso8601String(),
      });
      expect(sync.pendingCount, 0);
    });

    test('addBatch offline keeps the batch and queues it', () async {
      backend.on('POST', batchesPath, unreachable);

      await addLayers(provider);
      await sync.sync(pull: false);

      expect(provider.batches.single.name, 'Broilers A');
      expect(sync.pendingCount, 1);
    });

    group('with a loaded batch', () {
      setUp(() async {
        backend.on(
          'GET',
          batchesPath,
          (_) async => FakeSupabaseBackend.json([batchRow('b1')]),
        );
        await provider.fetchBatches();
        backend.requests.clear();
        notifications = 0;
      });

      test('updateBatch updates it locally, then patches the row', () async {
        backend.on('PATCH', batchesPath, (_) async => http.Response('', 204));

        await provider.updateBatch(
          id: 'b1',
          name: 'Renamed',
          typeOfBird: 'Kienyeji',
          initialCount: 90,
          age: 5,
          ageUnit: 'weeks',
          purchaseCost: 1200,
        );

        final updated = provider.batches.single;
        expect(updated.name, 'Renamed');
        expect(updated.initialCount, 90);
        expect(updated.createdAt, DateTime.utc(2025, 3, 1));
        expect(notifications, greaterThan(0));

        await sync.sync(pull: false);
        final patch = backend.requestsTo(batchesPath, method: 'PATCH').single;
        expect(patch.url.queryParameters['id'], 'eq.b1');
        expect(jsonDecode(patch.body), {
          'name': 'Renamed',
          'type_of_bird': 'Kienyeji',
          'initial_count': 90,
          'age': 5,
          'age_unit': 'weeks',
          'purchase_cost': 1200,
        });
      });

      test('an edit the server hasn\'t taken yet survives a refresh', () async {
        // Rejected once, so it is still queued when the refresh runs.
        backend.on(
          'PATCH',
          batchesPath,
          (_) async => FakeSupabaseBackend.json({
            'code': '23502',
            'message': 'not yet',
          }, status: 400),
        );

        await provider.updateBatch(
          id: 'b1',
          name: 'Renamed',
          typeOfBird: 'Layers',
          initialCount: 1,
          age: 1,
          ageUnit: 'days',
          purchaseCost: 0,
        );
        await sync.refresh(force: true);

        expect(provider.batches.single.name, 'Renamed');
        expect(sync.pendingCount, 1);
      });

      test('removeBatch drops it locally, then deletes the row', () async {
        backend.on('DELETE', batchesPath, (_) async => http.Response('', 204));

        await provider.removeBatch('b1');

        expect(provider.batches, isEmpty);
        expect(notifications, greaterThan(0));

        await sync.sync(pull: false);
        final delete = backend.requestsTo(batchesPath, method: 'DELETE').single;
        expect(delete.url.queryParameters['id'], 'eq.b1');
      });
    });
  });

  test('ChickenBatch rows from the server parse', () {
    expect(ChickenBatch.fromJson(batchRow('x')).typeOfBird, 'Layers');
  });
}

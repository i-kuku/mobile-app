import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';

import '../helpers/fake_supabase.dart';

const batchesPath = '/rest/v1/batches';

Map<String, dynamic> batchRow(String id, {String name = 'Batch'}) => {
  'id': id,
  'user_id': fakeUserId,
  'name': name,
  'type_of_bird': 'Layers',
  'initial_count': 100,
  'age': 2,
  'age_unit': 'weeks',
  'created_at': '2025-03-01T00:00:00.000Z',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final backend = FakeSupabaseBackend();

  setUpAll(() => initFakeSupabase(backend));

  setUp(backend.reset);
  tearDown(signOutFakeUser);

  group('signed out', () {
    test('fetchBatches does not query the server', () async {
      final provider = BatchProvider();
      await provider.fetchBatches();
      expect(provider.batches, isEmpty);
      expect(backend.requestsTo(batchesPath), isEmpty);
    });

    test('addBatch throws and sends nothing', () async {
      await expectLater(
        BatchProvider().addBatch(
          name: 'A',
          typeOfBird: 'Layers',
          initialCount: 1,
          age: 1,
          ageUnit: 'days',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authenticated'),
          ),
        ),
      );
      expect(backend.requestsTo(batchesPath), isEmpty);
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

    test('fetchBatches loads the user\'s batches newest first', () async {
      backend.on(
        'GET',
        batchesPath,
        (_) async => FakeSupabaseBackend.json([batchRow('b2'), batchRow('b1')]),
      );

      await provider.fetchBatches();

      expect(provider.batches.map((b) => b.id), ['b2', 'b1']);
      final query = backend.requestsTo(batchesPath).single.url.queryParameters;
      expect(query['user_id'], 'eq.$fakeUserId');
      expect(query['order'], 'created_at.desc.nullslast');
      expect(notifications, 2);
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
      await provider.fetchBatches();

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

        await provider.fetchBatches();

        expect(provider.batches.map((b) => b.id), ['b1']);
      },
    );

    test('addBatch inserts for the current user then refreshes', () async {
      backend.on('POST', batchesPath, (_) async => http.Response('', 201));
      backend.on(
        'GET',
        batchesPath,
        (_) async =>
            FakeSupabaseBackend.json([batchRow('b1', name: 'Broilers A')]),
      );

      await provider.addBatch(
        name: 'Broilers A',
        typeOfBird: 'Broilers',
        initialCount: 50,
        age: 3,
        ageUnit: 'days',
      );

      final insert = backend.requestsTo(batchesPath, method: 'POST').single;
      expect(jsonDecode(insert.body), {
        'user_id': fakeUserId,
        'name': 'Broilers A',
        'type_of_bird': 'Broilers',
        'initial_count': 50,
        'age': 3,
        'age_unit': 'days',
      });
      expect(provider.batches.single.name, 'Broilers A');
    });

    test('addBatch rethrows server errors', () async {
      backend.on(
        'POST',
        batchesPath,
        (_) async =>
            FakeSupabaseBackend.json({'message': 'denied'}, status: 403),
      );

      await expectLater(
        provider.addBatch(
          name: 'A',
          typeOfBird: 'Layers',
          initialCount: 1,
          age: 1,
          ageUnit: 'days',
        ),
        throwsA(anything),
      );
      expect(backend.requestsTo(batchesPath, method: 'GET'), isEmpty);
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

      test('updateBatch patches the row and updates it locally', () async {
        backend.on('PATCH', batchesPath, (_) async => http.Response('', 204));

        await provider.updateBatch(
          id: 'b1',
          name: 'Renamed',
          typeOfBird: 'Kienyeji',
          initialCount: 90,
          age: 5,
          ageUnit: 'weeks',
        );

        final patch = backend.requestsTo(batchesPath, method: 'PATCH').single;
        expect(patch.url.queryParameters['id'], 'eq.b1');
        expect(jsonDecode(patch.body), {
          'name': 'Renamed',
          'type_of_bird': 'Kienyeji',
          'initial_count': 90,
          'age': 5,
          'age_unit': 'weeks',
        });
        final updated = provider.batches.single;
        expect(updated.name, 'Renamed');
        expect(updated.initialCount, 90);
        expect(updated.createdAt, DateTime.utc(2025, 3, 1));
        expect(notifications, 1);
      });

      test('updateBatch for an unknown id does not notify', () async {
        backend.on('PATCH', batchesPath, (_) async => http.Response('', 204));
        await provider.updateBatch(
          id: 'missing',
          name: 'x',
          typeOfBird: 'x',
          initialCount: 1,
          age: 1,
          ageUnit: 'days',
        );
        expect(provider.batches.single.name, 'Batch');
        expect(notifications, 0);
      });

      test(
        'updateBatch rethrows and leaves local state alone on error',
        () async {
          backend.on(
            'PATCH',
            batchesPath,
            (_) async =>
                FakeSupabaseBackend.json({'message': 'denied'}, status: 403),
          );

          await expectLater(
            provider.updateBatch(
              id: 'b1',
              name: 'Renamed',
              typeOfBird: 'Layers',
              initialCount: 1,
              age: 1,
              ageUnit: 'days',
            ),
            throwsA(anything),
          );
          expect(provider.batches.single.name, 'Batch');
        },
      );

      test('removeBatch deletes the row and drops it locally', () async {
        backend.on('DELETE', batchesPath, (_) async => http.Response('', 204));

        await provider.removeBatch('b1');

        final delete = backend.requestsTo(batchesPath, method: 'DELETE').single;
        expect(delete.url.queryParameters['id'], 'eq.b1');
        expect(provider.batches, isEmpty);
        expect(notifications, 1);
      });

      test('removeBatch keeps the batch when the server errors', () async {
        backend.on(
          'DELETE',
          batchesPath,
          (_) async =>
              FakeSupabaseBackend.json({'message': 'denied'}, status: 403),
        );

        await provider.removeBatch('b1');

        expect(provider.batches.map((b) => b.id), ['b1']);
        expect(notifications, 0);
      });
    });
  });

  test('ChickenBatch rows from the server parse', () {
    expect(ChickenBatch.fromJson(batchRow('x')).typeOfBird, 'Layers');
  });
}

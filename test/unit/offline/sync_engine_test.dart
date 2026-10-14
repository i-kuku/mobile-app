import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ikuku/shared/offline/offline_services.dart';

import '../../helpers/fake_supabase.dart';

const batchesPath = '/rest/v1/batches';
const salePath = '/rest/v1/sale';

Map<String, dynamic> batch(String id, {String name = 'Batch'}) => {
  'id': id,
  'user_id': fakeUserId,
  'name': name,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final backend = FakeSupabaseBackend();

  late LocalStore store;
  late ConnectivityService connectivity;
  late SyncEngine sync;

  setUpAll(() => initFakeSupabase(backend));

  setUp(() async {
    backend.reset();
    store = await LocalStore.inMemory();
    connectivity = ConnectivityService.fixed();
    sync = SyncEngine(
      store: store,
      connectivity: connectivity,
      requestTimeout: const Duration(seconds: 2),
      maxRejections: 3,
    );
  });

  tearDown(() async {
    sync.dispose();
    await signOutFakeUser();
  });

  /// Answers every pull with no rows.
  void emptyServer() {
    for (final table in [
      'users',
      'farms',
      'batches',
      'inventory_items',
      'daily_records',
      'batch_records',
      'sale',
    ]) {
      backend.on(
        'GET',
        '/rest/v1/$table',
        (_) async => FakeSupabaseBackend.json([]),
      );
    }
  }

  test('does nothing while nobody is signed in', () async {
    await sync.saveRow('batches', batch('b1'));
    await sync.sync();

    expect(backend.requests, isEmpty);
    expect(sync.pendingCount, 1);
  });

  group('signed in', () {
    setUp(() async {
      await signInFakeUser(backend);
      emptyServer();
    });

    test('a saved row is on the device at once and queued', () async {
      await sync.saveRow('batches', batch('b1', name: 'Layers A'));

      expect(store.row('batches', 'b1')?['name'], 'Layers A');
      expect(sync.pendingCount, 1);
      expect(backend.requests, isEmpty);
    });

    test(
      'sync upserts queued rows, oldest first, then empties the outbox',
      () async {
        backend.on('POST', batchesPath, (_) async => http.Response('', 201));
        await sync.saveRow('batches', batch('b1'));
        await sync.saveRow('batches', batch('b2'));

        await sync.sync(pull: false);

        final posts = backend.requestsTo(batchesPath, method: 'POST');
        expect(posts.map((r) => jsonDecode(r.body)['id']), ['b1', 'b2']);
        expect(posts.first.headers['Prefer'], contains('merge-duplicates'));
        expect(sync.pendingCount, 0);
      },
    );

    test(
      'keeps changes queued and the data on the device when offline',
      () async {
        backend.on('POST', batchesPath, unreachable);
        await sync.saveRow('batches', batch('b1'));

        await sync.sync();

        expect(sync.pendingCount, 1);
        expect(store.row('batches', 'b1'), isNotNull);
        expect(connectivity.isOnline, isFalse);
        // It stops at the first failure instead of hammering the network.
        expect(backend.requestsTo(batchesPath), hasLength(1));
      },
    );

    test(
      'sends what was queued offline once the server answers again',
      () async {
        backend.on('POST', batchesPath, unreachable);
        await sync.saveRow('batches', batch('b1'));
        await sync.sync();

        backend.on('POST', batchesPath, (_) async => http.Response('', 201));
        await sync.sync();

        expect(sync.pendingCount, 0);
        expect(connectivity.isOnline, isTrue);
      },
    );

    test('a server error stops the push and keeps the change', () async {
      backend.on(
        'POST',
        batchesPath,
        (_) async => FakeSupabaseBackend.json({'message': 'down'}, status: 503),
      );
      await sync.saveRow('batches', batch('b1'));
      await sync.saveRow('batches', batch('b2'));

      await sync.sync(pull: false);

      expect(backend.requestsTo(batchesPath), hasLength(1));
      expect(sync.pendingCount, 2);
      expect(sync.parkedCount, 0);
    });

    test('a rejected change does not hold up changes to other rows', () async {
      backend.on('POST', batchesPath, (request) async {
        return jsonDecode(request.body)['id'] == 'bad'
            ? FakeSupabaseBackend.json({
                'code': '23502',
                'message': 'null value',
              }, status: 400)
            : http.Response('', 201);
      });
      await sync.saveRow('batches', batch('bad'));
      await sync.saveRow('batches', batch('good'));

      await sync.sync(pull: false);

      expect(sync.outbox.pending.single.recordId, 'bad');
      expect(sync.outbox.pending.single.attempts, 1);
    });

    test('later changes to a rejected row wait behind it', () async {
      backend.on(
        'POST',
        batchesPath,
        (_) async => FakeSupabaseBackend.json({
          'code': '23502',
          'message': 'no',
        }, status: 400),
      );
      backend.on('DELETE', batchesPath, (_) async => http.Response('', 204));
      await sync.saveRow('batches', batch('b1'));
      await sync.deleteRow('batches', 'b1');

      await sync.sync(pull: false);

      expect(backend.requestsTo(batchesPath, method: 'DELETE'), isEmpty);
      expect(sync.pendingCount, 2);
    });

    test('parks a change the server keeps rejecting, and can retry or '
        'discard it', () async {
      var reject = true;
      backend.on('POST', batchesPath, (_) async {
        return reject
            ? FakeSupabaseBackend.json({
                'code': '42501',
                'message': 'rls',
              }, status: 403)
            : http.Response('', 201);
      });
      await sync.saveRow('batches', batch('b1'));

      for (var i = 0; i < 3; i++) {
        await sync.sync(pull: false);
      }
      expect(sync.parkedCount, 1);
      expect(sync.pendingCount, 0);

      // Parked changes are not sent again on their own.
      await sync.sync(pull: false);
      expect(backend.requestsTo(batchesPath, method: 'POST'), hasLength(3));

      reject = false;
      await sync.retryParked();
      expect(sync.parkedCount, 0);
      expect(sync.pendingCount, 0);
    });

    test('discarding a parked change lets the server copy come back', () async {
      backend.on(
        'POST',
        batchesPath,
        (_) async => FakeSupabaseBackend.json({
          'code': '42501',
          'message': 'rls',
        }, status: 403),
      );
      backend.on(
        'GET',
        batchesPath,
        (_) async => FakeSupabaseBackend.json([batch('b1', name: 'Server')]),
      );
      await sync.saveRow('batches', batch('b1', name: 'Local'));
      for (var i = 0; i < 3; i++) {
        await sync.sync(pull: false);
      }

      await sync.discardParked();

      expect(sync.parkedCount, 0);
      expect(store.row('batches', 'b1')?['name'], 'Server');
    });

    test('a duplicate insert counts as sent', () async {
      backend.on(
        'POST',
        salePath,
        (_) async => FakeSupabaseBackend.json({
          'code': '23505',
          'message': 'dup',
        }, status: 409),
      );
      await sync.insertRow('sale', {'amount': 10});

      await sync.sync(pull: false);

      expect(sync.pendingCount, 0);
      expect(sync.parkedCount, 0);
    });

    test('refreshes an expired token and tries again', () async {
      var tokenRefreshed = false;
      backend.on('POST', '/auth/v1/token', (_) async {
        tokenRefreshed = true;
        return FakeSupabaseBackend.json(fakeSession());
      });
      backend.on('POST', batchesPath, (_) async {
        return tokenRefreshed
            ? http.Response('', 201)
            : FakeSupabaseBackend.json({
                'code': 'PGRST301',
                'message': 'JWT expired',
              }, status: 401);
      });
      await sync.saveRow('batches', batch('b1'));

      await sync.sync(pull: false);

      expect(tokenRefreshed, isTrue);
      expect(sync.pendingCount, 0);
    });

    test(
      'inserts drop the temporary id and the server row replaces it',
      () async {
        backend.on('POST', salePath, (_) async => http.Response('', 201));
        backend.on(
          'GET',
          salePath,
          (_) async => FakeSupabaseBackend.json([
            {'id': 41, 'amount': 10, 'user_id': fakeUserId},
          ]),
        );
        final localId = await sync.insertRow('sale', {
          'amount': 10,
          'user_id': fakeUserId,
        });
        expect(localId, startsWith(SyncEngine.localIdPrefix));
        expect(store.row('sale', localId)?['amount'], 10);

        await sync.sync();

        final insert = backend.requestsTo(salePath, method: 'POST').single;
        expect(jsonDecode(insert.body), {'amount': 10, 'user_id': fakeUserId});
        expect(store.rows('sale').map((r) => r['id']), [41]);
      },
    );

    test('deleting an unsent insert just forgets it', () async {
      final localId = await sync.insertRow('sale', {'amount': 10});

      await sync.deleteRow('sale', localId);
      await sync.sync(pull: false);

      expect(sync.pendingCount, 0);
      expect(backend.requestsTo(salePath), isEmpty);
    });

    test('updates and deletes are filtered on their match', () async {
      backend.on(
        'PATCH',
        '/rest/v1/farms',
        (_) async => http.Response('', 204),
      );
      backend.on('DELETE', batchesPath, (_) async => http.Response('', 204));
      await store.put('farms', {'id': 'f1', 'farm_location': 'Old'});
      await sync.updateRow(
        'farms',
        localId: 'f1',
        values: {'farm_location': 'Nakuru'},
        match: {'user_id': fakeUserId},
      );
      await sync.deleteRow('batches', 'b9');

      expect(store.row('farms', 'f1')?['farm_location'], 'Nakuru');
      await sync.sync(pull: false);

      final patch = backend.requestsTo('/rest/v1/farms').single;
      expect(patch.url.queryParameters['user_id'], 'eq.$fakeUserId');
      expect(jsonDecode(patch.body), {'farm_location': 'Nakuru'});
      final delete = backend.requestsTo(batchesPath).single;
      expect(delete.url.queryParameters['id'], 'eq.b9');
    });

    test('an update needs a match, so it can never touch every row', () {
      expect(
        () => sync.updateRow('farms', localId: 'f1', values: {}, match: {}),
        throwsArgumentError,
      );
    });

    test('calls queued database functions', () async {
      backend.on(
        'POST',
        '/rest/v1/rpc/set_answer',
        (_) async => FakeSupabaseBackend.json(null),
      );
      await sync.callRpc('set_answer', {'p_answer': 'blue'});

      await sync.sync(pull: false);

      final call = backend.requestsTo('/rest/v1/rpc/set_answer').single;
      expect(jsonDecode(call.body), {'p_answer': 'blue'});
    });

    group('pull', () {
      test('replaces local rows with the server copy', () async {
        await store.put('batches', batch('gone'));
        backend.on(
          'GET',
          batchesPath,
          (_) async => FakeSupabaseBackend.json([batch('b1', name: 'Server')]),
        );

        await sync.sync();

        expect(store.rows('batches').map((r) => r['id']), ['b1']);
        final query = backend.requestsTo(batchesPath).single.url;
        expect(query.queryParameters['user_id'], 'eq.$fakeUserId');
        expect(sync.lastPulledAt, isNotNull);
      });

      test('keeps local edits and deletions the server has not seen', () async {
        // Rejected once, so still queued when the pull runs.
        final rejected = FakeSupabaseBackend.json({
          'code': '23502',
          'message': 'no',
        }, status: 400);
        backend.on('POST', batchesPath, (_) async => rejected);
        backend.on('DELETE', batchesPath, (_) async => rejected);
        await sync.saveRow('batches', batch('edited', name: 'Local'));
        await store.put('batches', batch('deleted'));
        await sync.deleteRow('batches', 'deleted');
        backend.on(
          'GET',
          batchesPath,
          (_) async => FakeSupabaseBackend.json([
            batch('edited', name: 'Server'),
            batch('deleted'),
            batch('other'),
          ]),
        );

        await sync.sync();

        expect(store.row('batches', 'edited')?['name'], 'Local');
        expect(store.row('batches', 'deleted'), isNull);
        expect(store.row('batches', 'other'), isNotNull);
      });

      test('leaves local data alone when offline', () async {
        await store.put('batches', batch('b1'));
        backend.on('GET', '/rest/v1/users', unreachable);

        await sync.sync();

        expect(store.row('batches', 'b1'), isNotNull);
        expect(connectivity.isOnline, isFalse);
        expect(backend.requestsTo(batchesPath), isEmpty);
      });

      test('keeps a table it cannot read and fetches the rest', () async {
        await store.put('batches', batch('b1'));
        backend.on(
          'GET',
          batchesPath,
          (_) async => FakeSupabaseBackend.json({'message': 'no'}, status: 404),
        );
        backend.on(
          'GET',
          '/rest/v1/farms',
          (_) async => FakeSupabaseBackend.json([
            {'id': 'f1', 'user_id': fakeUserId},
          ]),
        );

        await sync.sync();

        expect(store.row('batches', 'b1'), isNotNull);
        expect(store.row('farms', 'f1'), isNotNull);
      });

      test('never keeps the recovery answer', () async {
        backend.on(
          'GET',
          '/rest/v1/users',
          (_) async => FakeSupabaseBackend.json([
            {
              'id': fakeUserId,
              'full_name': 'Jane',
              'recovery_answer': 'secret',
            },
          ]),
        );

        await sync.sync();

        expect(store.row('users', fakeUserId), {
          'id': fakeUserId,
          'full_name': 'Jane',
        });
      });

      test(
        'fetches batch records for the user\'s daily records in chunks',
        () async {
          final dailyIds = [for (var i = 0; i < 60; i++) 'd$i'];
          backend.on(
            'GET',
            '/rest/v1/daily_records',
            (_) async => FakeSupabaseBackend.json([
              for (final id in dailyIds) {'id': id, 'user_id': fakeUserId},
            ]),
          );
          backend.on(
            'GET',
            '/rest/v1/batch_records',
            (request) async => FakeSupabaseBackend.json([
              {'id': 'r${backend.requestsTo('/rest/v1/batch_records').length}'},
            ]),
          );

          await sync.sync();

          final requests = backend.requestsTo('/rest/v1/batch_records');
          expect(requests, hasLength(2));
          expect(
            requests.first.url.queryParameters['daily_record_id'],
            startsWith('in.("d0","d1",'),
          );
          expect(store.rows('batch_records'), hasLength(2));
        },
      );
    });

    test('folds calls made during a sync into one follow-up', () async {
      final first = sync.sync();
      final second = sync.sync();
      final third = sync.sync();
      await Future.wait([first, second, third]);

      // One run plus one follow-up, each pulling users once.
      expect(backend.requestsTo('/rest/v1/users'), hasLength(2));
    });

    test('refresh skips the pull when it just ran', () async {
      await sync.refresh();
      await sync.refresh();
      expect(backend.requestsTo('/rest/v1/users'), hasLength(1));

      await sync.refresh(force: true);
      expect(backend.requestsTo('/rest/v1/users'), hasLength(2));
    });

    group('cachedQuery', () {
      test('returns and saves the server answer', () async {
        final result = await sync.cachedQuery('k', (_) async => {'n': 1});

        expect(result.value, {'n': 1});
        expect(result.isFresh, isTrue);
        expect(store.cached('k')?.value, {'n': 1});
      });

      test('falls back to the saved answer when offline', () async {
        await sync.cachedQuery('k', (_) async => {'n': 1});
        backend.on('GET', salePath, unreachable);

        final offline = await sync.cachedQuery(
          'k',
          (client) => client.from('sale').select(),
        );

        expect(offline.isFresh, isFalse);
        expect(offline.value, {'n': 1});
        expect(offline.savedAt, isNotNull);
        expect(connectivity.isOnline, isFalse);
      });

      test('returns nothing when offline with nothing saved', () async {
        backend.on('GET', '/rest/v1/sale', unreachable);
        final result = await sync.cachedQuery(
          'none',
          (client) => client.from('sale').select(),
        );
        expect(result.value, isNull);
        expect(result.isFresh, isFalse);
      });
    });
  });
}

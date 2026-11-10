import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/dev/dev_backend.dart';
import 'package:ikuku/dev/dev_seed.dart';
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 10, 23, 12);

  late MemoryDevBackendStorage storage;
  late DevBackend backend;
  late SupabaseClient client;

  SupabaseClient clientFor(DevBackend backend) => SupabaseClient(
    DevBackend.url,
    DevBackend.publishableKey,
    httpClient: backend,
    authOptions: const AuthClientOptions(
      autoRefreshToken: false,
      authFlowType: AuthFlowType.implicit,
    ),
    // Stops .rpc() retrying. Table queries don't get these options in
    // supabase 2.x, so a failing GET there still retries for seven seconds.
    postgrestOptions: const PostgrestClientOptions(retryEnabled: false),
  );

  setUp(() async {
    storage = MemoryDevBackendStorage();
    backend = await DevBackend.open(storage: storage, now: now);
    client = clientFor(backend);
  });

  tearDown(() => client.dispose());

  Future<void> signIn() => client.auth.signInWithPassword(
    email: DevSeed.email,
    password: DevSeed.password,
  );

  group('auth', () {
    test('signs in the seeded developer account', () async {
      final res = await client.auth.signInWithPassword(
        email: 'DEV@ikuku.test',
        password: DevSeed.password,
      );

      expect(res.session, isNotNull);
      expect(res.user?.id, DevSeed.userId);
      expect(res.user?.email, DevSeed.email);
    });

    test('rejects a wrong password the way Supabase does', () async {
      await expectLater(
        client.auth.signInWithPassword(email: DevSeed.email, password: 'nope'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Invalid login credentials'),
          ),
        ),
      );
    });

    test('signs up new accounts, once per email', () async {
      final res = await client.auth.signUp(
        email: 'new@ikuku.test',
        password: 'secret1',
      );
      expect(res.session, isNotNull);

      await expectLater(
        client.auth.signUp(email: DevSeed.email, password: 'secret1'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('User already registered'),
          ),
        ),
      );
    });

    test('refreshes a session', () async {
      await signIn();
      final first = client.auth.currentSession!.refreshToken;

      final res = await client.auth.refreshSession();

      expect(res.session?.refreshToken, isNot(first));
      expect(res.user?.id, DevSeed.userId);
    });

    test('accepts the fixed one-time code', () async {
      await client.auth.signInWithOtp(email: DevSeed.email);
      final res = await client.auth.verifyOTP(
        email: DevSeed.email,
        token: DevBackend.otpCode,
        type: OtpType.magiclink,
      );
      expect(res.user?.id, DevSeed.userId);
    });
  });

  group('tables', () {
    test('anonymous requests see nothing', () async {
      expect(await client.from('batches').select(), isEmpty);
    });

    test('a signed-in user sees their rows, ordered', () async {
      await signIn();

      final rows = await client
          .from('batches')
          .select()
          .eq('user_id', DevSeed.userId)
          .order('created_at', ascending: false);

      expect(rows.map((r) => r['name']), ['Broilers B', 'Layers A']);
    });

    test('filters with eq, in, gte, lt and limit', () async {
      await signIn();

      final feeds = await client
          .from('inventory_items')
          .select('name, quantity')
          .eq('category', 'feeds')
          .gte('quantity', 25)
          .lt('quantity', 100);
      final records = await client
          .from('batch_records')
          .select()
          .inFilter('daily_record_id', [
            '00000000-0000-4000-8000-0000000000d1',
            '00000000-0000-4000-8000-0000000000d2',
          ]);
      final limited = await client.from('sale').select().limit(2);

      expect(feeds, [
        {'name': 'Layers Mash', 'quantity': 25},
      ]);
      expect(records, hasLength(2));
      expect(limited, hasLength(2));
    });

    test('upserts, updates and deletes', () async {
      await signIn();
      final row = {
        'id': 'b-new',
        'user_id': DevSeed.userId,
        'name': 'Kienyeji C',
        'initial_count': 40,
      };

      await client.from('batches').upsert(row);
      await client.from('batches').upsert({...row, 'initial_count': 45});
      await client
          .from('batches')
          .update({'name': 'Renamed'})
          .eq('id', 'b-new');
      final updated = await client
          .from('batches')
          .select()
          .eq('id', 'b-new')
          .single();
      await client.from('batches').delete().eq('id', 'b-new');

      expect(updated['name'], 'Renamed');
      expect(updated['initial_count'], 45);
      expect(updated['created_at'], isNotNull);
      expect(backend.rows('batches').where((r) => r['id'] == 'b-new'), isEmpty);
    });

    test('gives sales numeric ids and other rows uuids', () async {
      await signIn();

      final sale = await client
          .from('sale')
          .insert({'user_id': DevSeed.userId, 'sale_type': 'eggs', 'amount': 5})
          .select()
          .single();
      final farm = await client
          .from('farms')
          .insert({'user_id': DevSeed.userId, 'farm_name': 'Second'})
          .select()
          .single();

      expect(sale['id'], 4);
      expect(farm['id'], hasLength(36));
    });

    test('maybeSingle returns null when nothing matches', () async {
      await signIn();
      expect(
        await client.from('farms').select().eq('id', 'none').maybeSingle(),
        isNull,
      );
    });

    test('enforces the notifications unique key', () async {
      await signIn();
      final note = {
        'user_id': DevSeed.userId,
        'type': 'prediction',
        'reference_key': 'prediction_ready',
      };
      await client.from('user_notifications').insert({...note, 'id': 'n1'});

      await expectLater(
        client.from('user_notifications').upsert({...note, 'id': 'n2'}),
        throwsA(
          isA<PostgrestException>().having((e) => e.code, 'code', '23505'),
        ),
      );
    });

    test('refuses rows for another user', () async {
      await signIn();
      await expectLater(
        client.from('batches').insert({'user_id': 'someone-else', 'name': 'x'}),
        throwsA(
          isA<PostgrestException>().having((e) => e.code, 'code', '42501'),
        ),
      );
    });

    test('refuses reports against another user\'s day', () async {
      await signIn();
      await expectLater(
        client.from('batch_records').insert({
          'daily_record_id': 'someone-elses-day',
          'eggs_collected': 10,
        }),
        throwsA(
          isA<PostgrestException>().having((e) => e.code, 'code', '42501'),
        ),
      );
    });

    test('sorts and filters NULLs as PostgreSQL does', () async {
      await signIn();
      // Unlike the seeded batches, this one has no age unit.
      await client.from('batches').insert({
        'id': 'b-null',
        'user_id': DevSeed.userId,
        'name': 'No age',
      });

      final ascending = await client
          .from('batches')
          .select('id')
          .order('age_unit', ascending: true);
      final descending = await client
          .from('batches')
          .select('id')
          .order('age_unit', ascending: false);
      final notDays = await client
          .from('batches')
          .select('id')
          .neq('age_unit', 'days');

      expect(ascending.last['id'], 'b-null');
      expect(descending.last['id'], 'b-null');
      expect(notDays.map((r) => r['id']), isNot(contains('b-null')));
    });

    test('rejects queries it can\'t answer like PostgREST', () async {
      await signIn();
      final rejected = throwsA(
        isA<PostgrestException>().having((e) => e.code, 'code', 'PGRST100'),
      );

      await expectLater(
        client.from('batches').select().not('name', 'is', null),
        rejected,
      );
      await expectLater(
        client.from('batches').select().or('name.eq.a,name.eq.b'),
        rejected,
      );
      await expectLater(
        client.from('batch_records').select('daily_records!inner(record_date)'),
        rejected,
      );
    });

    test('answers unknown tables like PostgREST', () async {
      await signIn();
      await expectLater(
        client.from('nope').select(),
        throwsA(
          isA<PostgrestException>().having((e) => e.code, 'code', '42P01'),
        ),
      );
    });
  });

  group('database functions', () {
    test('get_financial_summary totals the dev data', () async {
      await signIn();

      final rows =
          await client.rpc(
                'get_financial_summary',
                params: {'p_batch_id': null},
              )
              as List;
      final summary = rows.single as Map<String, dynamic>;

      expect(summary['total_sales'], 6400);
      expect(summary['eggs_sales'], 2100);
      expect(summary['total_expenses'], greaterThan(0));
    });

    test('delete_user_account removes the user\'s reports too', () async {
      await signIn();
      expect(backend.rows('batch_records'), isNotEmpty);

      await client.rpc('delete_user_account');

      expect(backend.rows('daily_records'), isEmpty);
      expect(backend.rows('batch_records'), isEmpty);
      expect(backend.rows('batches'), isEmpty);
    });

    test('exec_sql does not exist, as in production', () async {
      await expectLater(
        client.rpc('exec_sql', params: {'sql': 'select 1'}),
        throwsA(
          isA<PostgrestException>().having((e) => e.code, 'code', 'PGRST202'),
        ),
      );
    });
  });

  test('offline, requests fail like a dropped connection', () async {
    await signIn();
    backend.online.value = false;

    Object? error;
    try {
      await client.from('batches').select();
    } catch (e) {
      error = e;
    }

    expect(error, isNotNull);
    expect(isNetworkError(error!), isTrue);
  });

  test('keeps its data between launches, until reset', () async {
    await signIn();
    await client.from('batches').insert({
      'id': 'kept',
      'user_id': DevSeed.userId,
      'name': 'Kept',
    });

    final reopened = await DevBackend.open(storage: storage, now: now);
    final reset = await DevBackend.open(
      storage: storage,
      reset: true,
      now: now,
    );

    expect(reopened.rows('batches').map((r) => r['id']), contains('kept'));
    expect(reset.rows('batches').map((r) => r['id']), isNot(contains('kept')));
  });

  test('works with the sync engine, offline and back', () async {
    final sync = SyncEngine(
      store: await LocalStore.inMemory(),
      connectivity: ConnectivityService.fixed(),
      client: () => client,
      requestTimeout: const Duration(seconds: 2),
    );
    addTearDown(sync.dispose);
    await signIn();

    await sync.sync();
    expect(sync.store.rows(LocalTables.batches), hasLength(2));
    expect(sync.store.rows(LocalTables.batchRecords), hasLength(3));
    expect(sync.store.rows(LocalTables.sales), hasLength(3));

    backend.online.value = false;
    await sync.saveRow(LocalTables.batches, {
      'id': 'offline-batch',
      'user_id': DevSeed.userId,
      'name': 'Made offline',
      'created_at': now.toUtc().toIso8601String(),
    });
    await sync.sync();
    expect(sync.pendingCount, 1);
    expect(sync.connectivity.isOnline, isFalse);

    backend.online.value = true;
    await sync.sync();
    expect(sync.pendingCount, 0);
    expect(
      backend.rows('batches').map((r) => r['name']),
      contains('Made offline'),
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/home/provider/analytics_provider.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

import '../helpers/fake_supabase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final backend = FakeSupabaseBackend();
  late SyncEngine sync;

  setUpAll(() => initFakeSupabase(backend));
  setUp(() async {
    backend.reset();
    sync = (await initOfflineServices(pullSpecs: const [])).sync;
  });
  tearDown(() async {
    await resetOfflineServices();
    await signOutFakeUser();
  });

  test('starts with an empty summary', () {
    final provider = AnalyticsProvider();
    expect(provider.isLoading, isFalse);
    expect(provider.summary.totalBirds, 0);
  });

  test('toggleLoadingState flips and notifies', () {
    final provider = AnalyticsProvider();
    var notifications = 0;
    provider.addListener(() => notifications++);
    provider.toggleLoadingState();
    expect(provider.isLoading, isTrue);
    provider.toggleLoadingState();
    expect(provider.isLoading, isFalse);
    expect(notifications, 2);
  });

  test('fetchSummary without a user sends nothing and stops loading', () async {
    final provider = AnalyticsProvider();
    final loadingStates = <bool>[];
    provider.addListener(() => loadingStates.add(provider.isLoading));

    await provider.fetchSummary();

    expect(backend.requests, isEmpty);
    expect(loadingStates, [true, false]);
    expect(provider.summary.totalBirds, 0);
  });

  group('signed in', () {
    late AnalyticsProvider provider;

    setUp(() async {
      await signInFakeUser(backend);
      final store = sync.store;
      await store.put(LocalTables.users, {
        'id': fakeUserId,
        'full_name': 'Jane Wanjiku',
      });
      // await store.putAll(LocalTables.batches, [
      //   {'id': 'b1', 'initial_count': 200},
      //   {'id': 'b2', 'initial_count': 120},
      // ]);
      await store.putAll(LocalTables.batches, [
        {
          'id': 'b1',
          'user_id': fakeUserId,
          'type_of_bird': 'broiler',
          'initial_count': 200,
        },
        {
          'id': 'b2',
          'user_id': fakeUserId,
          'type_of_bird': 'layer',
          'initial_count': 120,
        },
      ]);
      await store.putAll(LocalTables.inventoryItems, [
        {'id': 'i1', 'category': 'feeds', 'quantity': 10},
        {'id': 'i2', 'category': 'feeds', 'quantity': 2},
        {'id': 'i3', 'category': 'medicines', 'quantity': 99},
      ]);
      await store.putAll(LocalTables.batchRecords, [
        {
          'id': 'r1',
          'batch_id': 'b2',
          'eggs_collected': 1000,
          'eggs_standard': 200,
        },
        {'id': 'r2', 'eggs_collected': 500},
        {'id': 'r3', 'eggs_collected': null},
      ]);
      provider = AnalyticsProvider();
    });

    tearDown(() => provider.dispose());

    test('fetchSummary totals what is on the device', () async {
      final loadingStates = <bool>[];
      provider.addListener(() => loadingStates.add(provider.isLoading));

      await provider.fetchSummary();

      expect(provider.summary.totalBirds, 320);
      expect(provider.summary.totalFeeds, 12);
      expect(provider.summary.totalEggs, 1700);
      expect(provider.summary.userName, 'Jane Wanjiku');
      expect(loadingStates.first, isTrue);
      expect(loadingStates.last, isFalse);
    });

    test('birds total subtracts reductions and chicken sales', () async {
      await sync.store.putAll(LocalTables.batchRecords, [
        {
          'id': 'r9',
          'batch_id': 'b1',
          'chickens_died': 10,
          'chickens_stolen': 5,
        },
      ]);
      await sync.store.put(LocalTables.sales, {
        'id': 's1',
        'sale_type': 'chicken',
        'sub_type': 'broiler',
        'quantity': 20,
      });

      await provider.fetchSummary();

      // 320 - 15 reduced - 20 sold
      expect(provider.summary.totalBirds, 285);
    });
    test('works offline', () async {
      sync.connectivity.reportUnreachable();

      await provider.fetchSummary();

      expect(provider.summary.totalBirds, 320);
    });

    test('updates as soon as something is recorded', () async {
      await provider.fetchSummary();

      // await sync.saveRow(LocalTables.batches, {
      //   'id': 'b3',
      //   'initial_count': 30,
      // }
      await sync.saveRow(LocalTables.batches, {
        'id': 'b3',
        'user_id': fakeUserId,
        'type_of_bird': 'kienyeji',
        'initial_count': 30,
      });

      expect(provider.summary.totalBirds, 350);

      expect(provider.summary.totalBirds, 350);
    });

    test('falls back when the profile has no name', () async {
      await sync.store.put(LocalTables.users, {
        'id': fakeUserId,
        'full_name': '  ',
      });

      await provider.fetchSummary();

      expect(provider.summary.userName, 'type_here');
    });
  });
}

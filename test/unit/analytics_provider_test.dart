import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/home/provider/analytics_provider.dart';

import '../helpers/fake_supabase.dart';

const statsPath = '/rest/v1/user_dashboard_stats';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final backend = FakeSupabaseBackend();

  setUpAll(() => initFakeSupabase(backend));
  setUp(backend.reset);
  tearDown(signOutFakeUser);

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

    expect(backend.requestsTo(statsPath), isEmpty);
    expect(loadingStates, [true, false]);
    expect(provider.summary.totalBirds, 0);
  });

  group('signed in', () {
    setUp(() => signInFakeUser(backend));

    test('fetchSummary loads the current user\'s stats', () async {
      backend.on(
        'GET',
        statsPath,
        (_) async => FakeSupabaseBackend.json({
          'user_id': fakeUserId,
          'total_birds': 320,
          'total_feeds': 12,
          'total_eggs': 1500,
          'full_name': 'Jane Wanjiku',
        }),
      );
      final provider = AnalyticsProvider();
      final loadingStates = <bool>[];
      provider.addListener(() => loadingStates.add(provider.isLoading));

      await provider.fetchSummary();

      final request = backend.requestsTo(statsPath).single;
      expect(request.url.queryParameters['user_id'], 'eq.$fakeUserId');
      expect(request.headers['Accept'], 'application/vnd.pgrst.object+json');
      expect(provider.summary.totalBirds, 320);
      expect(provider.summary.totalFeeds, 12);
      expect(provider.summary.totalEggs, 1500);
      expect(provider.summary.userName, 'Jane Wanjiku');
      expect(loadingStates, [true, false]);
    });

    test(
      'fetchSummary keeps the previous summary when the query fails',
      () async {
        backend.on(
          'GET',
          statsPath,
          (_) async =>
              FakeSupabaseBackend.json({'total_birds': 5, 'full_name': 'Jane'}),
        );
        final provider = AnalyticsProvider();
        await provider.fetchSummary();

        backend.on(
          'GET',
          statsPath,
          (_) async => FakeSupabaseBackend.json({
            'code': 'PGRST116',
            'message': 'no rows',
          }, status: 406),
        );
        await provider.fetchSummary();

        expect(provider.summary.totalBirds, 5);
        expect(provider.isLoading, isFalse);
      },
    );
  });
}

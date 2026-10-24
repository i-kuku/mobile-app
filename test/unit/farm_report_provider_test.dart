import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

import '../helpers/fake_supabase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final backend = FakeSupabaseBackend();
  late SyncEngine sync;
  late FarmReportProvider provider;

  setUpAll(() => initFakeSupabase(backend));

  setUp(() async {
    backend.reset();
    sync = (await initOfflineServices(pullSpecs: const [])).sync;
    await signInFakeUser(backend);
    provider = FarmReportProvider();
  });

  tearDown(() async {
    await resetOfflineServices();
    await signOutFakeUser();
  });

  test('submitting offline saves the report on the phone', () async {
    backend.on('POST', '/rest/v1/daily_records', unreachable);
    provider.updateEggMetrics(collected: 40);

    final ok = await provider.submitDailyReport(batchId: 'b1');
    await sync.sync(pull: false);

    expect(ok, isTrue);
    final daily = sync.store.rows(LocalTables.dailyRecords).single;
    final record = sync.store.rows(LocalTables.batchRecords).single;
    expect(daily['user_id'], fakeUserId);
    expect(record['daily_record_id'], daily['id']);
    expect(record['batch_id'], 'b1');
    expect(record['eggs_collected'], 40);
    expect(sync.pendingCount, 2);
    expect(provider.eggsCollected, 0, reason: 'the form resets');
  });

  test('editing a report updates the same rows', () async {
    await provider.submitDailyReport(batchId: 'b1');
    final record = sync.store.rows(LocalTables.batchRecords).single;
    provider.loadReportForEditing({
      ...record,
      'daily_records': {'report_date': '2026-10-01'},
    });
    provider.updateChicken(died: 3);

    await provider.submitDailyReport(batchId: 'b1');

    final records = sync.store.rows(LocalTables.batchRecords);
    expect(records.single['id'], record['id']);
    expect(records.single['chickens_died'], 3);
    expect(sync.store.rows(LocalTables.dailyRecords), hasLength(1));
  });

  test('hasRecordedToday checks the reports on the phone', () async {
    expect(await provider.hasRecordedToday(), isFalse);

    await provider.submitDailyReport(batchId: 'b1');
    await provider.submitDailyReport(batchId: 'b2');

    // Two reports today still count as having recorded today.
    expect(await provider.hasRecordedToday(), isTrue);
    expect(backend.requests, isEmpty);
  });

  test('nothing is saved when nobody is signed in', () async {
    await signOutFakeUser();
    expect(await provider.submitDailyReport(batchId: 'b1'), isFalse);
    expect(sync.pendingCount, 0);
  });
}

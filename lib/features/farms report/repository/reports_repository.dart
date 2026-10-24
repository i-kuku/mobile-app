import 'package:ikuku/shared/offline/offline_services.dart';

/// Farm reports, read from the device so they open offline.
///
/// Rows come back shaped like the server's `batch_records` joined with
/// `daily_records` and `batches`, which is what the report screens parse.
class ReportsRepository {
  ReportsRepository({SyncEngine? sync}) : _syncOverride = sync;

  final SyncEngine? _syncOverride;
  SyncEngine get _sync => _syncOverride ?? OfflineServices.instance.sync;

  LocalStore get _store => _sync.store;

  /// Fires whenever the reports on the device change.
  Stream<void> get changes => _store.changes.where(
    (table) =>
        table == LocalTables.batchRecords ||
        table == LocalTables.dailyRecords ||
        table == LocalTables.batches,
  );

  /// Sends pending reports and fetches new ones, if the server can be
  /// reached. Never throws.
  Future<void> refresh() => _sync.refresh();

  Map<String, dynamic> _joined(Map<String, dynamic> record) {
    final daily = _store.row(
      LocalTables.dailyRecords,
      '${record['daily_record_id']}',
    );
    final batch = _store.row(LocalTables.batches, '${record['batch_id']}');
    return {
      ...record,
      'daily_records': daily == null
          ? null
          : {'report_date': daily['report_date'], 'user_id': daily['user_id']},
      'batches': batch == null
          ? null
          : {'name': batch['name'], 'type_of_bird': batch['type_of_bird']},
    };
  }

  List<Map<String, dynamic>> _reports() {
    final userId = _sync.currentUserId;
    if (userId == null) return [];
    final reports = _store
        .rows(LocalTables.batchRecords)
        .map(_joined)
        .where((r) => (r['daily_records'] as Map?)?['user_id'] == userId)
        .toList();
    String dateOf(Map<String, dynamic> r) =>
        (r['daily_records'] as Map)['report_date'] as String? ?? '';
    // Newest report date first.
    reports.sort((a, b) => dateOf(b).compareTo(dateOf(a)));
    return reports;
  }

  List<Map<String, dynamic>> fetchRecentReports({int limit = 5}) =>
      _reports().take(limit).toList();

  Map<String, dynamic>? fetchReportDetail(String reportId) {
    final record = _store.row(LocalTables.batchRecords, reportId);
    if (record == null || _sync.currentUserId == null) return null;
    final joined = _joined(record);
    final daily = joined['daily_records'] as Map?;
    return daily?['user_id'] == _sync.currentUserId ? joined : null;
  }

  List<Map<String, dynamic>> fetchAllReports() => _reports();

  /// The batch row for [batchId], as stored on the device.
  Map<String, dynamic>? fetchBatch(String batchId) =>
      _store.row(LocalTables.batches, batchId);

  /// Whether [batchId] already has a report dated [date].
  bool hasReportOn(String batchId, DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return _reports().any(
      (r) =>
          r['batch_id'] == batchId &&
          ((r['daily_records'] as Map)['report_date'] as String?)?.startsWith(
                dateStr,
              ) ==
              true,
    );
  }
}

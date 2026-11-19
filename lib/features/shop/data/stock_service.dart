import 'dart:math';
import 'package:ikuku/shared/offline/offline_services.dart';

class StockService {
  StockService({SyncEngine? sync}) : _syncOverride = sync;

  final SyncEngine? _syncOverride;
  SyncEngine get _sync => _syncOverride ?? OfflineServices.instance.sync;
  LocalStore get _store => _sync.store;

  static int _n(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? 0}') ?? 0;

  static String _norm(Object? v) => '${v ?? ''}'.trim().toLowerCase();

  static const birdTypes = ['kienyeji', 'broiler', 'layer'];

  

  /// Chickens of [birdType] still on the farm, including unsent changes.
  int chickensAvailable(String birdType) {
    final userId = _sync.currentUserId;
    final type = _norm(birdType);

    final batches = _store
        .rows(LocalTables.batches)
        .where(
          (b) =>
              b['user_id'] == userId && _norm(b['type_of_bird']).contains(type),
        );
    final batchIds = {for (final b in batches) '${b['id']}'};

    final initial = batches.fold<int>(0, (s, b) => s + _n(b['initial_count']));

    final reduced = _store
        .rows(LocalTables.batchRecords)
        .where((r) => batchIds.contains('${r['batch_id']}'))
        .fold<int>(
          0,
          (s, r) =>
              s +
              _n(r['chickens_curled']) +
              // Legacy: reports made before sales moved to My Shop may hold sold chickens.
              _n(r['chickens_sold']) +
              _n(r['chickens_sold']) +
              _n(r['chickens_died']) +
              _n(r['chickens_stolen']),
        );

    final sold = _store
        .rows(LocalTables.sales)
        .where(
          (s) =>
              _norm(s['sale_type']) == 'chicken' &&
              _norm(s['sub_type']) == type,
        )
        .fold<int>(0, (s, r) => s + _n(r['quantity']));

    return max(0, initial - reduced - sold);
  }

  /// All chickens still on the farm, across every bird type.
  int totalChickensAvailable() =>
      birdTypes.fold<int>(0, (sum, t) => sum + chickensAvailable(t));
}

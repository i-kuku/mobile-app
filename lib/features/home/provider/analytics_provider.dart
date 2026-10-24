import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ikuku/features/home/data/model/analytic_summary.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

/// The home screen's totals, worked out from the data on the device so they
/// include entries that haven't reached the server yet.
class AnalyticsProvider with ChangeNotifier {
  AnalyticsProvider({SyncEngine? sync}) : _syncOverride = sync;

  final SyncEngine? _syncOverride;
  SyncEngine get _sync => _syncOverride ?? OfflineServices.instance.sync;

  StreamSubscription<String>? _subscription;
  bool _isLoading = false;
  AnalyticSummary _summary = AnalyticSummary.fromJson({});

  bool get isLoading => _isLoading;
  AnalyticSummary get summary => _summary;

  static const _sourceTables = {
    LocalTables.batches,
    LocalTables.inventoryItems,
    LocalTables.batchRecords,
    LocalTables.users,
  };

  void toggleLoadingState() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  void _watch() {
    _subscription ??= _sync.store.changes
        .where(_sourceTables.contains)
        .listen((_) => _load());
  }

  static int _sum(Iterable<Map<String, dynamic>> rows, String column) => rows
      .fold(0, (total, row) => total + ((row[column] as num?) ?? 0).toInt());

  void _load() {
    final store = _sync.store;
    final userId = _sync.currentUserId;
    final fullName = userId == null
        ? null
        : store.row(LocalTables.users, userId)?['full_name'] as String?;

    _summary = AnalyticSummary.fromJson({
      'total_birds': _sum(store.rows(LocalTables.batches), 'initial_count'),
      'total_feeds': _sum(
        store
            .rows(LocalTables.inventoryItems)
            .where((item) => item['category'] == 'feeds'),
        'quantity',
      ),
      'total_eggs': _sum(
        store.rows(LocalTables.batchRecords),
        'eggs_collected',
      ),
      if (fullName != null && fullName.trim().isNotEmpty) 'full_name': fullName,
    });
    notifyListeners();
  }

  Future<void> fetchSummary() async {
    toggleLoadingState();
    try {
      if (_sync.currentUserId == null) return;
      _watch();
      _load();
      await _sync.refresh();
    } catch (e) {
      debugPrint('Could not refresh the summary: $e');
    } finally {
      toggleLoadingState();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ikuku/features/shop/model/sale_model.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

/// Sales, read from and recorded on the device first. New sales reach the
/// server in the background whenever there is a connection.
class SalesProvider extends ChangeNotifier {
  SalesProvider({SyncEngine? sync}) : _syncOverride = sync;

  final SyncEngine? _syncOverride;
  SyncEngine get _sync => _syncOverride ?? OfflineServices.instance.sync;

  StreamSubscription<String>? _subscription;
  List<SaleModel> _sales = [];
  bool _isLoading = false;

  List<SaleModel> get sales => _sales;

  /// True only while a first-ever load waits on the server.
  bool get isLoading => _isLoading;

  // Helper to check if two DateTimes fall on the same local day
  bool _isSameDay(DateTime date1, DateTime date2) {
    final d1 = date1.toLocal();
    final d2 = date2.toLocal();
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  // Calculate today's total sales
  double get todaytotalSales {
    final now = DateTime.now();
    return _sales
        .where((sale) => _isSameDay(sale.createdAt, now))
        .fold(0.0, (sum, sale) => sum + sale.amount);
  }

  // Get today's sales or fallback to the latest 5 sales
  List<SaleModel> get dashboardSales {
    final now = DateTime.now();
    final todaySales =
        _sales.where((sale) => _isSameDay(sale.createdAt, now)).toList();

    if (todaySales.isNotEmpty) {
      return todaySales;
    }
    return _sales.take(5).toList();
  }

  // Group all sales by Date
  Map<String, List<SaleModel>> get salesGroupedByDate {
    final Map<String, List<SaleModel>> grouped = {};
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    for (var sale in _sales) {
      final localDate = sale.createdAt.toLocal();
      String key;
      if (_isSameDay(localDate, now)) {
        key = 'Today';
      } else if (_isSameDay(localDate, yesterday)) {
        key = 'Yesterday';
      } else {
        key = '${localDate.day} ${_getMonthName(localDate.month)}';
      }

      grouped.putIfAbsent(key, () => []).add(sale);
    }
    return grouped;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _watch() {
    _subscription ??= _sync.store.changes
        .where((table) => table == LocalTables.sales)
        .listen((_) => _load());
  }

  void _load() {
    final loaded = <SaleModel>[];
    for (final row in _sync.store.rows(LocalTables.sales)) {
      try {
        loaded.add(SaleModel.fromJson(row));
      } catch (e) {
        debugPrint('Skipping unreadable sale ${row['id']}: $e');
      }
    }
    loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _sales = loaded;
    notifyListeners();
  }

  /// Shows the sales on the device at once, then refreshes them from the
  /// server if it can be reached.
  Future<void> fetchSales() async {
    if (_sync.currentUserId == null) return;
    _watch();
    _load();

    final firstLoad =
        _sales.isEmpty && _sync.lastPulledAt == null && _sync.isOnline;
    if (firstLoad) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      await _sync.refresh();
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Records [sale] on the device and queues it for the server.
  Future<void> addSale(SaleModel sale) async {
    final userId = _sync.currentUserId;
    if (userId == null) throw Exception('User is not authenticated.');

    _watch();
    await _sync.insertRow(LocalTables.sales, {
      ...sale.toJson(),
      'user_id': userId,
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

/// The farm store's items, read from and written to the device first.
/// Changes reach the server in the background whenever there is a
/// connection.
class InventoryProvider extends ChangeNotifier {
  InventoryProvider({SyncEngine? sync}) : _syncOverride = sync;

  final SyncEngine? _syncOverride;
  SyncEngine get _sync => _syncOverride ?? OfflineServices.instance.sync;

  StreamSubscription<String>? _subscription;
  final List<InventoryItem> _inventory = [];
  bool _isloading = false;

  List<InventoryItem> get inventory => _inventory;
  bool get isloading => _isloading;

  List<InventoryItem> get feeds =>
      _inventory.where((item) => item.category == 'feeds').toList();

  List<InventoryItem> get medicines =>
      _inventory.where((item) => item.category == 'medicines').toList();

  List<InventoryItem> get others =>
      _inventory.where((item) => item.category == 'others').toList();

  List get lowStockFeeds {
    return feeds.where((item) => (item.quantity as num).toDouble() < 30.0).toList();
  }

  void _watch() {
    _subscription ??= _sync.store.changes
        .where((table) => table == LocalTables.inventoryItems)
        .listen((_) => _load());
  }

  void _load() {
    final loaded = <InventoryItem>[];
    for (final row in _sync.store.rows(LocalTables.inventoryItems)) {
      try {
        loaded.add(InventoryItem.fromJson(row));
      } catch (e) {
        debugPrint('Skipping unreadable inventory item ${row['id']}: $e');
      }
    }
    loaded.sort((a, b) => b.addedOn.compareTo(a.addedOn));
    _inventory
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  /// Shows the items on the device at once, then refreshes them from the
  /// server if it can be reached.
  Future<void> fetchInventory() async {
    if (_sync.currentUserId == null) return;
    _watch();
    _load();

    // Only a first-ever load waits on the server; otherwise the device's
    // copy is shown straight away.
    final firstLoad =
        _inventory.isEmpty && _sync.lastPulledAt == null && _sync.isOnline;
    if (firstLoad) {
      _isloading = true;
      notifyListeners();
    }
    try {
      await _sync.refresh();
    } finally {
      if (_isloading) {
        _isloading = false;
        notifyListeners();
      }
    }
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    _watch();
    await _sync.saveRow(LocalTables.inventoryItems, item.toJson());
  }

  Future<void> deleteInventoryItem(String id) async {
    _watch();
    await _sync.deleteRow(LocalTables.inventoryItems, id);
  }

  Future<void> incrementQuantity(String id, int amount) async {
    final index = _inventory.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _watch();
    await _sync.updateRow(
      LocalTables.inventoryItems,
      localId: id,
      values: {'quantity': _inventory[index].quantity + amount},
      match: {'id': id},
    );
  }

  void clearInventory() {
    _inventory.clear();
    notifyListeners();
  }

  /// Saves an item's new details on the device and queues them for the
  /// server.
  Future<void> updateInventoryItem(InventoryItem updatedItem) async {
    _watch();
    await _sync.updateRow(
      LocalTables.inventoryItems,
      localId: updatedItem.id,
      values: updatedItem.toJson(),
      match: {'id': updatedItem.id},
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

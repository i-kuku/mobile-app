import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:uuid/uuid.dart';

/// The farmer's batches, read from and written to the device first. Changes
/// reach the server in the background whenever there is a connection.
class BatchProvider extends ChangeNotifier {
  BatchProvider({SyncEngine? sync}) : _syncOverride = sync;

  final SyncEngine? _syncOverride;
  SyncEngine get _sync => _syncOverride ?? OfflineServices.instance.sync;

  StreamSubscription<String>? _subscription;
  final List<ChickenBatch> _batches = [];

  List<ChickenBatch> get batches => _batches;

  /// Starts following the device's copy, so changes from a background sync
  /// show up without asking.
  void _watch() {
    _subscription ??= _sync.store.changes
        .where((table) => table == LocalTables.batches)
        .listen((_) => _load());
  }

  void _load() {
    final loaded = <ChickenBatch>[];
    for (final row in _sync.store.rows(LocalTables.batches)) {
      try {
        loaded.add(ChickenBatch.fromJson(row));
      } catch (e) {
        debugPrint('Skipping unreadable batch ${row['id']}: $e');
      }
    }
    loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _batches
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  /// Shows the batches on the device at once, then refreshes them from the
  /// server if it can be reached.
  Future<void> fetchBatches() async {
    if (_sync.currentUserId == null) return;
    _watch();
    _load();
    await _sync.refresh();
  }

  Future<void> addBatch({
    required String name,
    required String typeOfBird,
    required int initialCount,
    required int age,
    required String ageUnit,
    required num purchaseCost,
  }) async {
    final userId = _sync.currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    _watch();
    await _sync.saveRow(LocalTables.batches, {
      'id': const Uuid().v4(),
      'user_id': userId,
      'name': name,
      'type_of_bird': typeOfBird,
      'initial_count': initialCount,
      'age': age,
      'age_unit': ageUnit,
      'purchase_cost': purchaseCost,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> updateBatch({
    required String id,
    required String name,
    required String typeOfBird,
    required int initialCount,
    required int age,
    required String ageUnit,
    required num purchaseCost,
  }) async {
    _watch();
    await _sync.updateRow(
      LocalTables.batches,
      localId: id,
      values: {
        'name': name,
        'type_of_bird': typeOfBird,
        'initial_count': initialCount,
        'age': age,
        'age_unit': ageUnit,
        'purchase_cost': purchaseCost,
      },
      match: {'id': id},
    );
  }

  Future<void> removeBatch(String id) async {
    _watch();
    await _sync.deleteRow(LocalTables.batches, id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

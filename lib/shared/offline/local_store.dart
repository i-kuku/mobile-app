import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// The tables kept on the device. Names match the Supabase tables they
/// mirror so rows move between the two unchanged.
abstract final class LocalTables {
  static const batches = 'batches';
  static const inventoryItems = 'inventory_items';
  static const dailyRecords = 'daily_records';
  static const batchRecords = 'batch_records';
  static const sales = 'sale';
  static const users = 'users';
  static const farms = 'farms';

  /// Server results that can't be rebuilt from the tables above, keyed by
  /// whatever identifies the query (e.g. a financial summary per batch).
  static const cache = 'cache';

  /// Changes waiting to be sent to the server. See `Outbox`.
  static const outbox = 'outbox';

  /// Book-keeping about the store itself, such as whose data it holds.
  static const meta = 'meta';

  static const all = [
    batches,
    inventoryItems,
    dailyRecords,
    batchRecords,
    sales,
    users,
    farms,
    cache,
    outbox,
    meta,
  ];
}

/// Where a [LocalStore] keeps its rows between app launches. Each table is
/// a map of row id to the row encoded as JSON.
abstract class StorePersistence {
  Future<Map<String, String>> load(String table);
  Future<void> put(String table, Map<String, String> rows);
  Future<void> delete(String table, Iterable<String> ids);
  Future<void> clear(String table);
}

/// Keeps every table in its own Hive box.
class HiveStorePersistence implements StorePersistence {
  final Map<String, Box<String>> _boxes = {};

  static String boxName(String table) => 'local_$table';

  Future<Box<String>> _box(String table) async {
    final open = _boxes[table];
    if (open != null && open.isOpen) return open;
    final box = await Hive.openBox<String>(boxName(table));
    return _boxes[table] = box;
  }

  @override
  Future<Map<String, String>> load(String table) async {
    final box = await _box(table);
    return {for (final key in box.keys) key.toString(): ?box.get(key)};
  }

  @override
  Future<void> put(String table, Map<String, String> rows) async =>
      (await _box(table)).putAll(rows);

  @override
  Future<void> delete(String table, Iterable<String> ids) async =>
      (await _box(table)).deleteAll(ids);

  @override
  Future<void> clear(String table) async => (await _box(table)).clear();
}

/// Keeps nothing between launches; for tests.
class MemoryStorePersistence implements StorePersistence {
  final Map<String, Map<String, String>> tables = {};

  @override
  Future<Map<String, String>> load(String table) async =>
      Map.of(tables[table] ?? const {});

  @override
  Future<void> put(String table, Map<String, String> rows) async =>
      (tables[table] ??= {}).addAll(rows);

  @override
  Future<void> delete(String table, Iterable<String> ids) async {
    final rows = tables[table];
    if (rows == null) return;
    for (final id in ids) {
      rows.remove(id);
    }
  }

  @override
  Future<void> clear(String table) async => tables.remove(table);
}

/// The app's data on this device, which every screen reads from so the app
/// works the same with or without a connection.
///
/// Rows are JSON maps shaped like the matching Supabase rows and keyed by
/// their `id`. Reads are served from memory; writes update memory at once,
/// tell listeners on [changes], then persist.
class LocalStore {
  LocalStore._(this._persistence, this._tables);

  final StorePersistence _persistence;

  // Rows are held encoded so callers can never mutate stored state.
  final Map<String, Map<String, String>> _tables;

  final StreamController<String> _changes = StreamController.broadcast(
    sync: true,
  );

  /// Loads every table in [LocalTables.all] from [persistence].
  static Future<LocalStore> open(StorePersistence persistence) async {
    final tables = <String, Map<String, String>>{};
    for (final table in LocalTables.all) {
      try {
        tables[table] = await persistence.load(table);
      } catch (e) {
        // A corrupt table must not stop the app from starting. It is
        // refilled from the server on the next sync.
        debugPrint('[LocalStore] Could not load $table, starting empty: $e');
        tables[table] = {};
      }
    }
    return LocalStore._(persistence, tables);
  }

  /// An empty store that keeps nothing between launches; for tests.
  static Future<LocalStore> inMemory() => open(MemoryStorePersistence());

  /// The name of each table as it changes.
  Stream<String> get changes => _changes.stream;

  Map<String, String> _table(String table) =>
      _tables.putIfAbsent(table, () => {});

  static String idOf(Map<String, dynamic> row) {
    final id = row['id'];
    if (id == null) throw ArgumentError('A stored row needs an id: $row');
    return id.toString();
  }

  /// Every row in [table], in the order they were first written.
  List<Map<String, dynamic>> rows(String table) => [
    for (final json in _table(table).values)
      jsonDecode(json) as Map<String, dynamic>,
  ];

  Map<String, dynamic>? row(String table, String id) {
    final json = _table(table)[id];
    return json == null ? null : jsonDecode(json) as Map<String, dynamic>;
  }

  bool contains(String table, String id) => _table(table).containsKey(id);

  Future<void> put(String table, Map<String, dynamic> row) =>
      putAll(table, [row]);

  Future<void> putAll(String table, Iterable<Map<String, dynamic>> rows) {
    final encoded = {for (final row in rows) idOf(row): jsonEncode(row)};
    if (encoded.isEmpty) return Future.value();
    _table(table).addAll(encoded);
    _changes.add(table);
    return _persist(() => _persistence.put(table, encoded));
  }

  Future<void> remove(String table, String id) {
    if (_table(table).remove(id) == null) return Future.value();
    _changes.add(table);
    return _persist(() => _persistence.delete(table, [id]));
  }

  /// Makes [table] hold exactly [rows].
  Future<void> replaceAll(String table, Iterable<Map<String, dynamic>> rows) {
    final encoded = {for (final row in rows) idOf(row): jsonEncode(row)};
    final current = _table(table);
    if (mapEquals(current, encoded)) return Future.value();

    final removed = current.keys.where((id) => !encoded.containsKey(id));
    final removedIds = removed.toList();
    _tables[table] = encoded;
    _changes.add(table);
    return _persist(() async {
      if (removedIds.isNotEmpty) {
        await _persistence.delete(table, removedIds);
      }
      await _persistence.put(table, encoded);
    });
  }

  /// Empties every table, e.g. when someone else signs in on this phone.
  Future<void> clear() async {
    for (final table in LocalTables.all) {
      if (_table(table).isEmpty) continue;
      _table(table).clear();
      _changes.add(table);
      await _persist(() => _persistence.clear(table));
    }
  }

  Future<void> _persist(Future<void> Function() write) async {
    try {
      await write();
    } catch (e) {
      // The change is still in memory for this session; losing it on a
      // restart is better than crashing the screen that made it.
      debugPrint('[LocalStore] Could not save to disk: $e');
    }
  }

  // --- meta ---------------------------------------------------------------

  static const _ownerKey = 'owner';

  /// The id of the user whose data this store holds.
  String? get ownerId => row(LocalTables.meta, _ownerKey)?['user_id'];

  Future<void> setOwner(String userId) =>
      put(LocalTables.meta, {'id': _ownerKey, 'user_id': userId});

  /// Clears the store if it holds someone else's data, then records [userId]
  /// as its owner.
  Future<void> claimFor(String userId) async {
    final owner = ownerId;
    if (owner == userId) return;
    if (owner != null) {
      debugPrint('[LocalStore] New user on this device; clearing old data');
      await clear();
    }
    await setOwner(userId);
  }

  // --- cache --------------------------------------------------------------

  /// A cached server result saved with [putCached], or null.
  CachedValue? cached(String key) {
    final row = this.row(LocalTables.cache, key);
    if (row == null) return null;
    return CachedValue(
      row['value'],
      DateTime.tryParse(row['saved_at'] as String? ?? ''),
    );
  }

  Future<void> putCached(String key, Object? value) => put(LocalTables.cache, {
    'id': key,
    'value': value,
    'saved_at': DateTime.now().toUtc().toIso8601String(),
  });
}

/// A server result kept for offline use, and when it was fetched.
class CachedValue {
  const CachedValue(this.value, this.savedAt);

  final Object? value;
  final DateTime? savedAt;
}

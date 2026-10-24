import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'connectivity_service.dart';
import 'local_store.dart';
import 'network_errors.dart';
import 'outbox.dart';

/// What a [PullSpec] query can see while a pull is running.
class PullContext {
  PullContext(this.store, this.userId);

  final LocalStore store;
  final String userId;

  /// Rows fetched so far in this pull, by table.
  final Map<String, List<Map<String, dynamic>>> pulled = {};

  /// Ids in [table], preferring what was just fetched over the local copy.
  List<String> idsOf(String table) => [
    for (final row in pulled[table] ?? store.rows(table)) LocalStore.idOf(row),
  ];
}

typedef PullQuery =
    Future<List<Map<String, dynamic>>> Function(
      SupabaseClient client,
      PullContext context,
    );

/// How to fetch one table's rows for the signed-in user.
class PullSpec {
  const PullSpec(this.table, this.query);

  final String table;
  final PullQuery query;
}

List<Map<String, dynamic>> _rows(Object? response) =>
    List<Map<String, dynamic>>.from(response as List);

// PostgREST puts `in` filters in the URL, so keep each request short.
const _idsPerRequest = 50;

/// The tables kept on the device, in the order they are fetched.
final List<PullSpec> defaultPullSpecs = [
  PullSpec(LocalTables.users, (client, ctx) async {
    final rows = _rows(
      await client.from('users').select().eq('id', ctx.userId),
    );
    // The recovery answer is a secret; there's no reason to keep it here.
    return [for (final row in rows) Map.of(row)..remove('recovery_answer')];
  }),
  PullSpec(
    LocalTables.farms,
    (client, ctx) async =>
        _rows(await client.from('farms').select().eq('user_id', ctx.userId)),
  ),
  PullSpec(
    LocalTables.batches,
    (client, ctx) async => _rows(
      await client
          .from('batches')
          .select()
          .eq('user_id', ctx.userId)
          .order('created_at', ascending: false),
    ),
  ),
  PullSpec(
    LocalTables.inventoryItems,
    (client, ctx) async => _rows(
      await client
          .from('inventory_items')
          .select()
          .eq('user_id', ctx.userId)
          .order('added_on', ascending: false),
    ),
  ),
  PullSpec(
    LocalTables.dailyRecords,
    (client, ctx) async => _rows(
      await client.from('daily_records').select().eq('user_id', ctx.userId),
    ),
  ),
  PullSpec(LocalTables.batchRecords, (client, ctx) async {
    final ids = ctx.idsOf(LocalTables.dailyRecords);
    final rows = <Map<String, dynamic>>[];
    for (final chunk in ids.slices(_idsPerRequest)) {
      rows.addAll(
        _rows(
          await client
              .from('batch_records')
              .select()
              .inFilter('daily_record_id', chunk),
        ),
      );
    }
    return rows;
  }),
  // All of them, not just the latest: NotificationsProvider checks this copy
  // to avoid creating a notification the server already has.
  PullSpec(
    LocalTables.userNotifications,
    (client, ctx) async => _rows(
      await client
          .from('user_notifications')
          .select()
          .eq('user_id', ctx.userId)
          .order('created_at', ascending: false),
    ),
  ),
  PullSpec(
    LocalTables.sales,
    (client, ctx) async => _rows(
      await client
          .from('sale')
          .select()
          .eq('user_id', ctx.userId)
          .order('created_at', ascending: false),
    ),
  ),
];

/// A server result returned by [SyncEngine.cachedQuery].
class CachedResult {
  const CachedResult(this.value, this.savedAt, {required this.isFresh});

  /// The server's answer, or the last saved one; null if there's neither.
  final Object? value;

  /// When [value] came from the server.
  final DateTime? savedAt;

  /// Whether [value] was fetched just now rather than read from the cache.
  final bool isFresh;
}

/// Keeps the [LocalStore] and the server in step.
///
/// Screens write through [saveRow], [insertRow], [updateRow], [deleteRow]
/// and [callRpc]: each change lands on the device at once and joins the
/// [Outbox]. Whenever the server is reachable the outbox is sent in order,
/// then every table is refreshed from the server, keeping local rows whose
/// changes haven't been sent yet. Failures never reach the screen; the work
/// waits and is retried with backoff, when the network returns, and when the
/// app comes back to the foreground.
class SyncEngine extends ChangeNotifier with WidgetsBindingObserver {
  SyncEngine({
    required this.store,
    required this.connectivity,
    SupabaseClient Function()? client,
    List<PullSpec>? pullSpecs,
    this.requestTimeout = const Duration(seconds: 20),
    this.pushDelay = const Duration(milliseconds: 500),
    this.refreshInterval = const Duration(seconds: 30),
    this.maxRejections = 5,
  }) : outbox = Outbox(store),
       _client = client ?? (() => Supabase.instance.client),
       pullSpecs = pullSpecs ?? defaultPullSpecs;

  final LocalStore store;
  final Outbox outbox;
  final ConnectivityService connectivity;
  final List<PullSpec> pullSpecs;
  final SupabaseClient Function() _client;

  /// How long one request may take before it counts as unreachable.
  final Duration requestTimeout;

  /// How long to wait after a change before sending, so changes made
  /// together go out together.
  final Duration pushDelay;

  /// [refresh] skips fetching from the server if it did so this recently.
  final Duration refreshInterval;

  /// How many times the server may reject a change before it is parked.
  final int maxRejections;

  static const _minBackoff = Duration(seconds: 10);
  static const _maxBackoff = Duration(minutes: 5);

  Duration _backoff = _minBackoff;
  Timer? _pushTimer;
  Timer? _retryTimer;
  StreamSubscription<String>? _storeSubscription;
  bool _started = false;
  bool _disposed = false;

  Future<void>? _current;
  Future<void>? _followUp;
  bool _followUpPulls = false;

  bool _syncing = false;
  DateTime? _lastPulledAt;

  /// Whether changes are being sent or tables fetched right now.
  bool get isSyncing => _syncing;

  bool get isOnline => connectivity.isOnline;

  /// Changes made on this device the server hasn't confirmed yet.
  int get pendingCount => outbox.pending.length;

  /// Changes the server kept rejecting, waiting for [retryParked] or
  /// [discardParked].
  int get parkedCount => outbox.parked.length;

  /// When the device last had everything from the server.
  DateTime? get lastPulledAt => _lastPulledAt;

  static String _pulledKey(String table) => 'pulled:$table';

  /// Whether [table] has been fetched from the server on this device since
  /// its current owner signed in, so its local copy can be trusted to be
  /// complete.
  bool hasPulled(String table) =>
      store.contains(LocalTables.meta, _pulledKey(table));

  SupabaseClient? get _clientOrNull {
    try {
      return _client();
    } catch (_) {
      // Supabase isn't initialised, e.g. in a widget test.
      return null;
    }
  }

  /// The signed-in user, known even offline from the saved session.
  String? get currentUserId => _clientOrNull?.auth.currentUser?.id;

  /// Starts syncing on its own: now, when the network returns, after
  /// changes, and when the app is resumed.
  void start() {
    if (_started) return;
    _started = true;
    connectivity.addListener(_onConnectivityChanged);
    _storeSubscription = store.changes
        .where((table) => table == LocalTables.outbox)
        .listen((_) => _onOutboxChanged());
    WidgetsBinding.instance.addObserver(this);
    unawaited(sync());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refresh());
  }

  void _onConnectivityChanged() {
    _notify();
    if (!connectivity.isOnline) return;
    _backoff = _minBackoff;
    // A running sync is usually what just reached the server; starting
    // another would fetch every table twice.
    if (_syncing) return;
    unawaited(sync());
  }

  void _onOutboxChanged() {
    _notify();
    if (_syncing || !connectivity.hasNetwork) return;
    _pushTimer?.cancel();
    _pushTimer = Timer(pushDelay, () => unawaited(sync(pull: false)));
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // --- writing ------------------------------------------------------------

  // Each write below changes the device's copy and queues the change before
  // awaiting either, so both are in memory before anything else can run. A
  // pull landing while the write is saved to disk would otherwise find the
  // row with no queued change and replace it with the server's copy.

  /// Saves [row] on the device and queues it for the server. For tables
  /// whose ids the app creates, so sending it twice is harmless.
  ///
  /// Set [dropIfDuplicate] when the server rejecting the row as a duplicate
  /// means it already has the same thing under another id; the change and
  /// this local copy are then dropped instead of retried.
  Future<void> saveRow(
    String table,
    Map<String, dynamic> row, {
    bool dropIfDuplicate = false,
  }) async {
    await Future.wait([
      store.put(table, row),
      outbox.add(
        kind: ChangeKind.upsert,
        target: table,
        recordId: LocalStore.idOf(row),
        payload: row,
        dropIfDuplicate: dropIfDuplicate,
      ),
    ]);
  }

  /// Merges [fields], which must include the `id`, into the local row and
  /// queues an upsert of just those fields. For rows the server keeps more
  /// columns on than the app knows about, such as `users`.
  Future<void> mergeRow(String table, Map<String, dynamic> fields) async {
    final id = LocalStore.idOf(fields);
    await Future.wait([
      store.put(table, {...?store.row(table, id), ...fields}),
      outbox.add(
        kind: ChangeKind.upsert,
        target: table,
        recordId: id,
        payload: fields,
      ),
    ]);
  }

  /// Saves [row] on the device under a temporary id and queues it for a
  /// table whose ids the server assigns. Returns the temporary id; the row
  /// takes its real id at the next refresh after it's sent.
  Future<String> insertRow(String table, Map<String, dynamic> row) async {
    final localId = '$localIdPrefix${const Uuid().v4()}';
    await Future.wait([
      store.put(table, {...row, 'id': localId}),
      outbox.add(
        kind: ChangeKind.insert,
        target: table,
        recordId: localId,
        payload: Map.of(row)..remove('id'),
      ),
    ]);
    return localId;
  }

  /// Ids from [insertRow] start with this until the server assigns one.
  static const localIdPrefix = 'local-';

  /// Merges [values] into the local row [localId], if there is one, and
  /// queues an update of the server rows matching [match].
  Future<void> updateRow(
    String table, {
    required String localId,
    required Map<String, dynamic> values,
    required Map<String, dynamic> match,
  }) async {
    if (match.isEmpty) throw ArgumentError('An update needs a match filter');
    final current = store.row(table, localId);
    await Future.wait([
      if (current != null) store.put(table, {...current, ...values}),
      outbox.add(
        kind: ChangeKind.update,
        target: table,
        recordId: localId,
        payload: values,
        match: match,
      ),
    ]);
  }

  /// Queues an update of the server rows matching [match] without touching
  /// the device's copy, for values that shouldn't be kept on the phone.
  Future<void> queueUpdate(
    String table, {
    required String recordId,
    required Map<String, dynamic> values,
    required Map<String, dynamic> match,
  }) async {
    if (match.isEmpty) throw ArgumentError('An update needs a match filter');
    await outbox.add(
      kind: ChangeKind.update,
      target: table,
      recordId: recordId,
      payload: values,
      match: match,
    );
  }

  /// Removes row [id] from the device and queues its deletion.
  Future<void> deleteRow(String table, String id) async {
    if (id.startsWith(localIdPrefix)) {
      // The server never had it; forget the queued insert instead.
      await Future.wait([
        store.remove(table, id),
        for (final change in outbox.all)
          if (change.target == table && change.recordId == id)
            outbox.remove(change),
      ]);
      return;
    }
    await Future.wait([
      store.remove(table, id),
      outbox.add(
        kind: ChangeKind.delete,
        target: table,
        recordId: id,
        match: {'id': id},
      ),
    ]);
  }

  /// Queues a call to the database function [function].
  Future<void> callRpc(String function, Map<String, dynamic> params) =>
      outbox.add(kind: ChangeKind.rpc, target: function, payload: params);

  // --- reading from the server --------------------------------------------

  /// Runs [query] and saves its result under [key]. When the server can't
  /// answer, returns the saved result from last time instead.
  Future<CachedResult> cachedQuery(
    String key,
    Future<Object?> Function(SupabaseClient client) query,
  ) async {
    final client = _clientOrNull;
    if (client != null) {
      try {
        final value = await query(client).timeout(requestTimeout);
        connectivity.reportReachable();
        await store.putCached(key, value);
        return CachedResult(value, DateTime.now(), isFresh: true);
      } catch (e) {
        _report(e);
        debugPrint('[Sync] Using saved $key: $e');
      }
    }
    final saved = store.cached(key);
    return CachedResult(saved?.value, saved?.savedAt, isFresh: false);
  }

  void _report(Object error) {
    if (isNetworkError(error)) {
      connectivity.reportUnreachable();
    } else {
      connectivity.reportReachable();
    }
  }

  // --- syncing ------------------------------------------------------------

  /// Sends pending changes, and fetches from the server unless it did so in
  /// the last [refreshInterval].
  Future<void> refresh({bool force = false}) {
    final last = _lastPulledAt;
    final recent =
        last != null && DateTime.now().difference(last) < refreshInterval;
    return sync(pull: force || !recent);
  }

  /// Sends pending changes, then, if [pull], fetches every table. Calls
  /// made while a sync is running are folded into one follow-up run.
  Future<void> sync({bool pull = true}) {
    if (_current == null) {
      return _current = _run(pull).whenComplete(() => _current = null);
    }
    _followUpPulls |= pull;
    return _followUp ??= _current!.then((_) {
      final pulls = _followUpPulls;
      _followUp = null;
      _followUpPulls = false;
      return sync(pull: pulls);
    });
  }

  Future<void> _run(bool pull) async {
    // Screens start syncs from initState, i.e. while widgets build. Yield
    // first, so listeners such as the status banner aren't told to rebuild
    // in the middle of a build.
    await Future<void>.value();
    final client = _clientOrNull;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null || _disposed) return;

    _pushTimer?.cancel();
    _retryTimer?.cancel();
    _syncing = true;
    _notify();
    // Anything queued after this point is picked up by a follow-up run.
    final newestAtStart = outbox.all.lastOrNull?.seq ?? 0;
    var ok = false;
    try {
      ok = await _push(client) && (!pull || await _pull(client, userId));
    } catch (e, stack) {
      // A bug here must not take the app down; the work stays queued.
      debugPrint('[Sync] Unexpected failure: $e\n$stack');
    } finally {
      _syncing = false;
      _notify();
    }
    if (_disposed) return;

    if (ok) _backoff = _minBackoff;
    final pending = outbox.pending;
    if (!ok || pending.any((c) => c.attempts > 0)) {
      _scheduleRetry();
    } else if (pending.any((c) => c.seq > newestAtStart)) {
      unawaited(sync(pull: false));
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    // Without a network there is nothing to try; its return restarts us.
    if (!connectivity.hasNetwork) return;
    final delay = _backoff;
    _backoff = Duration(
      milliseconds: min(
        _backoff.inMilliseconds * 2,
        _maxBackoff.inMilliseconds,
      ),
    );
    _retryTimer = Timer(delay, () => unawaited(sync()));
  }

  /// Sends the outbox in order. False if it stopped because the server
  /// couldn't be reached or was failing.
  Future<bool> _push(SupabaseClient client) async {
    if (outbox.pending.isEmpty) return true;
    if (!await _ensureFreshSession(client)) return false;

    final tried = <String>{};
    // Changes to a row wait behind any earlier change to it that hasn't
    // landed, so the server applies them in the order they were made.
    final heldRows = {for (final change in outbox.parked) ?_rowKey(change)};
    var refreshedSession = false;

    while (true) {
      final next = outbox.pending.firstWhereOrNull(
        (c) => !tried.contains(c.id) && !heldRows.contains(_rowKey(c)),
      );
      if (next == null) return true;
      tried.add(next.id);

      try {
        await _send(client, next).timeout(requestTimeout);
        connectivity.reportReachable();
        await outbox.remove(next);
      } catch (e) {
        switch (classifyFailure(e)) {
          case FailureKind.network:
            connectivity.reportUnreachable();
            return false;
          case FailureKind.transient:
            connectivity.reportReachable();
            return false;
          case FailureKind.auth:
            connectivity.reportReachable();
            if (refreshedSession || !await _refreshSession(client)) {
              return false;
            }
            refreshedSession = true;
            tried.remove(next.id);
          case FailureKind.rejected:
            connectivity.reportReachable();
            if (isDuplicateRow(e)) {
              if (next.kind == ChangeKind.insert) {
                // An earlier send landed but its answer was lost.
                await outbox.remove(next);
                continue;
              }
              if (next.dropIfDuplicate) {
                // The server has the same thing under another id; this
                // copy is a duplicate, and the next pull brings the original.
                await outbox.remove(next);
                if (next.recordId case final id?) {
                  await store.remove(next.target, id);
                }
                continue;
              }
            }
            final attempts = next.attempts + 1;
            debugPrint('[Sync] Server rejected ${next.target} change: $e');
            await outbox.update(
              next.copyWith(
                attempts: attempts,
                lastError: e.toString(),
                parked: attempts >= maxRejections,
              ),
            );
            if (_rowKey(next) case final key?) heldRows.add(key);
        }
      }
    }
  }

  static String? _rowKey(PendingChange change) =>
      change.recordId == null ? null : '${change.target}/${change.recordId}';

  Future<void> _send(SupabaseClient client, PendingChange change) async {
    switch (change.kind) {
      case ChangeKind.upsert:
        await client.from(change.target).upsert(change.payload);
      case ChangeKind.insert:
        await client.from(change.target).insert(change.payload);
      case ChangeKind.update:
        var query = client.from(change.target).update(change.payload);
        for (final MapEntry(:key, :value) in change.match.entries) {
          query = query.eq(key, value as Object);
        }
        await query;
      case ChangeKind.delete:
        var query = client.from(change.target).delete();
        for (final MapEntry(:key, :value) in change.match.entries) {
          query = query.eq(key, value as Object);
        }
        await query;
      case ChangeKind.rpc:
        await client.rpc(change.target, params: change.payload);
    }
  }

  Future<bool> _ensureFreshSession(SupabaseClient client) async {
    final session = client.auth.currentSession;
    if (session == null) return false;
    if (!session.isExpired) return true;
    return _refreshSession(client);
  }

  Future<bool> _refreshSession(SupabaseClient client) async {
    try {
      await client.auth.refreshSession().timeout(requestTimeout);
      connectivity.reportReachable();
      return true;
    } catch (e) {
      _report(e);
      debugPrint('[Sync] Could not refresh the session: $e');
      return false;
    }
  }

  Future<bool> _pull(SupabaseClient client, String userId) async {
    final context = PullContext(store, userId);
    var complete = true;
    for (final spec in pullSpecs) {
      try {
        final rows = await spec.query(client, context).timeout(requestTimeout);
        connectivity.reportReachable();
        context.pulled[spec.table] = rows;
        await _merge(spec.table, rows);
        if (!hasPulled(spec.table)) {
          await store.put(LocalTables.meta, {
            'id': _pulledKey(spec.table),
            'at': DateTime.now().toUtc().toIso8601String(),
          });
        }
      } catch (e) {
        if (isNetworkError(e)) {
          connectivity.reportUnreachable();
          return false;
        }
        // Keep the local copy of this table and carry on with the rest.
        connectivity.reportReachable();
        debugPrint('[Sync] Could not refresh ${spec.table}: $e');
        if (classifyFailure(e) != FailureKind.rejected) complete = false;
      }
    }
    // A pull that hit a passing failure is retried rather than counted.
    if (complete) _lastPulledAt = DateTime.now();
    return complete;
  }

  /// Replaces [table] with the server's rows, except rows changed on the
  /// device that the server hasn't caught up with yet.
  Future<void> _merge(String table, List<Map<String, dynamic>> serverRows) {
    final touched = outbox.touchedIds(table);
    final deleted = outbox.deletedIds(table);
    final merged = <String, Map<String, dynamic>>{
      for (final row in serverRows)
        if (!touched.contains(LocalStore.idOf(row))) LocalStore.idOf(row): row,
    };
    for (final id in touched) {
      if (deleted.contains(id)) continue;
      final local = store.row(table, id);
      if (local != null) merged[id] = local;
    }
    return store.replaceAll(table, merged.values);
  }

  /// Puts parked changes back in the queue and sends them.
  Future<void> retryParked() async {
    for (final change in outbox.parked) {
      await outbox.update(change.copyWith(attempts: 0, parked: false));
    }
    await sync();
  }

  /// Drops parked changes; the next refresh restores the server's copy.
  Future<void> discardParked() async {
    for (final change in outbox.parked) {
      await outbox.remove(change);
    }
    await sync();
  }

  @override
  void dispose() {
    _disposed = true;
    _pushTimer?.cancel();
    _retryTimer?.cancel();
    _storeSubscription?.cancel();
    if (_started) {
      connectivity.removeListener(_onConnectivityChanged);
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }
}

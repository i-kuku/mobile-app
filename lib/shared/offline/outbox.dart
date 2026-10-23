import 'local_store.dart';

/// What a [PendingChange] does on the server.
enum ChangeKind {
  /// Insert or replace the row in `payload`, matched on its `id`. Safe to
  /// send twice, so it is used for every table whose ids the app creates.
  upsert,

  /// Insert `payload` and let the server pick the id. Used for tables with
  /// server-generated ids.
  insert,

  /// Set the columns in `payload` on rows matching `match`.
  update,

  /// Delete rows matching `match`.
  delete,

  /// Call the database function `target` with `payload` as its arguments.
  rpc,
}

/// One change made on the device that the server hasn't confirmed yet.
class PendingChange {
  const PendingChange({
    required this.id,
    required this.seq,
    required this.kind,
    required this.target,
    this.recordId,
    this.payload = const {},
    this.match = const {},
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
    this.parked = false,
    this.dropIfDuplicate = false,
  });

  /// The change's key in the queue, derived from [seq].
  final String id;

  /// Position in the queue; changes are sent in ascending order.
  final int seq;
  final ChangeKind kind;

  /// The table, or for [ChangeKind.rpc] the function.
  final String target;

  /// The id of the local row this change belongs to, so a sync from the
  /// server doesn't overwrite the row before the change lands.
  final String? recordId;
  final Map<String, dynamic> payload;
  final Map<String, dynamic> match;
  final DateTime createdAt;

  /// How many times the server has rejected this change.
  final int attempts;
  final String? lastError;

  /// Set once the server has rejected the change too often to keep trying
  /// on its own. Parked changes wait for the farmer to retry or discard them.
  final bool parked;

  /// Set when the server refusing this as a duplicate means it already has
  /// the same thing under another id, e.g. a notification with the same
  /// reference key. The change and its local copy are then dropped.
  final bool dropIfDuplicate;

  PendingChange copyWith({int? attempts, String? lastError, bool? parked}) =>
      PendingChange(
        id: id,
        seq: seq,
        kind: kind,
        target: target,
        recordId: recordId,
        payload: payload,
        match: match,
        createdAt: createdAt,
        attempts: attempts ?? this.attempts,
        lastError: lastError ?? this.lastError,
        parked: parked ?? this.parked,
        dropIfDuplicate: dropIfDuplicate,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'seq': seq,
    'kind': kind.name,
    'target': target,
    'record_id': recordId,
    'payload': payload,
    'match': match,
    'created_at': createdAt.toUtc().toIso8601String(),
    'attempts': attempts,
    'last_error': lastError,
    'parked': parked,
    'drop_if_duplicate': dropIfDuplicate,
  };

  factory PendingChange.fromJson(Map<String, dynamic> json) => PendingChange(
    id: json['id'] as String,
    seq: json['seq'] as int,
    kind: ChangeKind.values.byName(json['kind'] as String),
    target: json['target'] as String,
    recordId: json['record_id'] as String?,
    payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
    match: Map<String, dynamic>.from(json['match'] as Map? ?? const {}),
    createdAt: DateTime.parse(json['created_at'] as String),
    attempts: json['attempts'] as int? ?? 0,
    lastError: json['last_error'] as String?,
    parked: json['parked'] as bool? ?? false,
    dropIfDuplicate: json['drop_if_duplicate'] as bool? ?? false,
  );
}

/// The queue of [PendingChange]s, kept in the [LocalStore] so it survives
/// the app being closed.
class Outbox {
  Outbox(this._store);

  final LocalStore _store;

  // Zero-padded so the stored keys sort in queue order.
  static String keyFor(int seq) => seq.toString().padLeft(12, '0');

  List<PendingChange>? _cache;
  int _cacheRevision = -1;

  /// Every change, oldest first, parked ones included. Decoded once per
  /// change to the queue rather than on every read.
  List<PendingChange> get all {
    final revision = _store.revisionOf(LocalTables.outbox);
    if (_cache == null || _cacheRevision != revision) {
      _cache = List.unmodifiable(
        _store.rows(LocalTables.outbox).map(PendingChange.fromJson).toList()
          ..sort((a, b) => a.seq.compareTo(b.seq)),
      );
      _cacheRevision = revision;
    }
    return _cache!;
  }

  /// Changes still being sent, oldest first.
  List<PendingChange> get pending => all.where((c) => !c.parked).toList();

  /// Changes the server kept rejecting.
  List<PendingChange> get parked => all.where((c) => c.parked).toList();

  bool get isEmpty => all.isEmpty;

  int _nextSeq() {
    final changes = all;
    return changes.isEmpty ? 1 : changes.last.seq + 1;
  }

  Future<PendingChange> add({
    required ChangeKind kind,
    required String target,
    String? recordId,
    Map<String, dynamic> payload = const {},
    Map<String, dynamic> match = const {},
    bool dropIfDuplicate = false,
  }) async {
    final seq = _nextSeq();
    final change = PendingChange(
      id: keyFor(seq),
      seq: seq,
      kind: kind,
      target: target,
      recordId: recordId,
      payload: payload,
      match: match,
      createdAt: DateTime.now(),
      dropIfDuplicate: dropIfDuplicate,
    );
    await _save(change);
    return change;
  }

  Future<void> _save(PendingChange change) =>
      _store.put(LocalTables.outbox, change.toJson());

  Future<void> update(PendingChange change) => _save(change);

  Future<void> remove(PendingChange change) =>
      _store.remove(LocalTables.outbox, change.id);

  /// Ids of rows in [table] with a change still on its way, parked or not.
  /// Their local copy is newer than the server's.
  Set<String> touchedIds(String table) => {
    for (final change in all)
      if (change.target == table && change.recordId != null) change.recordId!,
  };

  /// Ids of rows in [table] deleted on the device but not yet on the server.
  Set<String> deletedIds(String table) => {
    for (final change in all)
      if (change.target == table &&
          change.kind == ChangeKind.delete &&
          change.recordId != null)
        change.recordId!,
  };

  bool touches(String table, String recordId) =>
      all.any((c) => c.target == table && c.recordId == recordId);
}

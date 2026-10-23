import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'dev_seed.dart';

/// Where the dev backend keeps its data between launches.
abstract class DevBackendStorage {
  Future<String?> read();
  Future<void> write(String json);
}

/// Keeps the dev backend's data in a Hive box on the device.
class HiveDevBackendStorage implements DevBackendStorage {
  static const _box = 'dev_backend';
  static const _key = 'state';

  Future<Box<String>> _open() => Hive.openBox<String>(_box);

  @override
  Future<String?> read() async => (await _open()).get(_key);

  @override
  Future<void> write(String json) async => (await _open()).put(_key, json);
}

/// Keeps nothing between launches; for tests.
class MemoryDevBackendStorage implements DevBackendStorage {
  String? json;

  @override
  Future<String?> read() async => json;

  @override
  Future<void> write(String json) async => this.json = json;
}

/// Stands in for the Supabase project during development, so the app can be
/// built and run without Supabase.
///
/// It answers the Supabase auth and REST calls the app makes from data kept
/// on the device, seeded with [DevSeed]'s developer account. The real
/// `SupabaseClient` talks to it through its `httpClient`, so every screen,
/// provider and the sync engine run their normal code.
///
/// Enabled only by `--dart-define=IKUKU_DEV_BACKEND=true` in a debug build.
/// Release builds refuse to start with it, and without the flag the compiler
/// drops it entirely, so it can never ship.
class DevBackend extends http.BaseClient {
  DevBackend._(this._storage, this._state);

  static const enabled = bool.fromEnvironment('IKUKU_DEV_BACKEND');

  /// Reseeds on start, discarding what developers changed.
  static const resetOnStart = bool.fromEnvironment('IKUKU_DEV_RESET');

  static const url = 'http://dev.ikuku.local';
  static const publishableKey = 'dev-publishable-key';

  /// The running backend, when [enabled].
  static DevBackend? instance;

  static Future<DevBackend> open({
    DevBackendStorage? storage,
    bool reset = false,
    DateTime? now,
  }) async {
    final store = storage ?? HiveDevBackendStorage();
    Map<String, dynamic>? state;
    if (!reset) {
      final json = await store.read();
      if (json != null) {
        try {
          state = jsonDecode(json) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('[DevBackend] Unreadable data, reseeding: $e');
        }
      }
    }
    // Through JSON, so the seed has the same plain types as saved data.
    state ??=
        jsonDecode(jsonEncode(DevSeed.build(now: now))) as Map<String, dynamic>;
    final backend = DevBackend._(store, state);
    await backend._save();
    return instance = backend;
  }

  final DevBackendStorage _storage;
  final Map<String, dynamic> _state;

  /// Turn off to make every request fail as if the phone had no connection.
  final ValueNotifier<bool> online = ValueNotifier(true);

  /// A copy of [table]'s rows, for tests and debugging.
  List<Map<String, dynamic>> rows(String table) => [
    for (final row in _table(table)) Map.of(row),
  ];

  List<Map<String, dynamic>> _table(String table) {
    final tables = _state['tables'] as Map<String, dynamic>;
    return (tables[table] as List).cast<Map<String, dynamic>>();
  }

  bool _hasTable(String table) =>
      (_state['tables'] as Map<String, dynamic>).containsKey(table);

  List<Map<String, dynamic>> get _authUsers =>
      (_state['auth_users'] as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> get _refreshTokens =>
      _state['refresh_tokens'] as Map<String, dynamic>;

  Future<void> _save() => _storage.write(jsonEncode(_state));

  // --- transport ------------------------------------------------------------

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bytes = await request.finalize().toBytes();
    if (!online.value) {
      // Fail the way a phone without a connection does.
      await Future<void>.delayed(const Duration(milliseconds: 150));
      throw http.ClientException(
        'Failed host lookup: dev.ikuku.local (dev backend is offline)',
        request.url,
      );
    }

    final headers = {
      for (final MapEntry(:key, :value) in request.headers.entries)
        key.toLowerCase(): value,
    };
    final body = utf8.decode(bytes, allowMalformed: true);
    _Reply reply;
    try {
      reply = _route(request.method, request.url, headers, body);
    } catch (e, stack) {
      debugPrint(
        '[DevBackend] ${request.method} ${request.url.path}: $e\n$stack',
      );
      reply = _Reply.json({'message': 'Dev backend error: $e'}, 500);
    }
    if (reply.changed) await _save();

    final out = utf8.encode(reply.body);
    return http.StreamedResponse(
      Stream.value(out),
      reply.status,
      contentLength: out.length,
      request: request,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  _Reply _route(
    String method,
    Uri url,
    Map<String, String> headers,
    String body,
  ) {
    final path = url.path;
    if (path.startsWith('/auth/v1/')) {
      return _auth(
        method,
        path.substring('/auth/v1/'.length),
        url,
        headers,
        body,
      );
    }
    if (path.startsWith('/rest/v1/rpc/')) {
      return _rpc(path.substring('/rest/v1/rpc/'.length), headers, body);
    }
    if (path.startsWith('/rest/v1/')) {
      return _rest(
        method,
        path.substring('/rest/v1/'.length),
        url,
        headers,
        body,
      );
    }
    if (path.startsWith('/storage/v1/')) {
      // Uploads are accepted but not kept; photos don't load in dev.
      return _Reply.json({'Key': path}, 200);
    }
    return _Reply.json({
      'message': 'Not in the dev backend: $method $path',
    }, 404);
  }

  // --- auth -----------------------------------------------------------------

  static const _uuid = Uuid();

  String _now() => DateTime.now().toUtc().toIso8601String();

  Map<String, dynamic> _publicUser(Map<String, dynamic> user) => {
    'id': user['id'],
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': user['email'],
    'email_confirmed_at': user['created_at'],
    'app_metadata': {
      'provider': 'email',
      'providers': ['email'],
    },
    'user_metadata': user['user_metadata'] ?? <String, dynamic>{},
    'created_at': user['created_at'],
    'updated_at': user['created_at'],
  };

  static String _base64(Map<String, dynamic> part) =>
      base64Url.encode(utf8.encode(jsonEncode(part))).replaceAll('=', '');

  _Reply _session(Map<String, dynamic> user) {
    final expires = DateTime.now().add(const Duration(hours: 1));
    final exp = expires.millisecondsSinceEpoch ~/ 1000;
    final refresh = 'dev-refresh-${_uuid.v4()}';
    _refreshTokens[refresh] = user['id'];
    final token = [
      _base64({'alg': 'HS256', 'typ': 'JWT'}),
      _base64({
        'sub': user['id'],
        'email': user['email'],
        'role': 'authenticated',
        'aud': 'authenticated',
        'exp': exp,
      }),
      'dev-signature',
    ].join('.');
    return _Reply.json(
      {
        'access_token': token,
        'token_type': 'bearer',
        'expires_in': 3600,
        'expires_at': exp,
        'refresh_token': refresh,
        'user': _publicUser(user),
      },
      200,
      changed: true,
    );
  }

  Map<String, dynamic>? _userById(Object? id) =>
      _authUsers.where((u) => u['id'] == id).firstOrNull;

  Map<String, dynamic>? _userByEmail(Object? email) => _authUsers
      .where(
        (u) =>
            (u['email'] as String).toLowerCase() ==
            '${email ?? ''}'.toLowerCase(),
      )
      .firstOrNull;

  /// The signed-in user's id from the bearer token, or null for anonymous
  /// requests. Throws [_Expired] for an expired token.
  String? _uid(Map<String, String> headers) {
    final auth = headers['authorization'] ?? '';
    if (!auth.startsWith('Bearer ')) return null;
    final parts = auth.substring(7).split('.');
    if (parts.length != 3) return null;
    try {
      final payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      final exp = payload['exp'] as int? ?? 0;
      if (exp * 1000 < DateTime.now().millisecondsSinceEpoch) {
        throw const _Expired();
      }
      final id = payload['sub'] as String?;
      return _userById(id) == null ? null : id;
    } on _Expired {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  static _Reply _authError(int status, String code, String message) =>
      _Reply.json({
        'code': status,
        'error_code': code,
        'msg': message,
        'error': code,
        'error_description': message,
      }, status);

  _Reply _auth(
    String method,
    String route,
    Uri url,
    Map<String, String> headers,
    String body,
  ) {
    final data = body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(body) as Map<String, dynamic>;
    switch ((method, route)) {
      case ('POST', 'token'):
        switch (url.queryParameters['grant_type']) {
          case 'password':
            final user = _userByEmail(data['email']);
            if (user == null || user['password'] != data['password']) {
              return _authError(
                400,
                'invalid_credentials',
                'Invalid login credentials',
              );
            }
            return _session(user);
          case 'refresh_token':
            final user = _userById(
              _refreshTokens.remove(data['refresh_token']),
            );
            if (user == null) {
              return _authError(
                400,
                'refresh_token_not_found',
                'Invalid Refresh Token: Refresh Token Not Found',
              );
            }
            return _session(user);
        }
      case ('POST', 'signup'):
        final email = '${data['email'] ?? ''}'.trim();
        final password = '${data['password'] ?? ''}';
        if (_userByEmail(email) != null) {
          return _authError(
            422,
            'user_already_exists',
            'User already registered',
          );
        }
        if (password.length < 6) {
          return _authError(
            422,
            'weak_password',
            'Password should be at least 6 characters.',
          );
        }
        final user = {
          'id': _uuid.v4(),
          'email': email,
          'password': password,
          'created_at': _now(),
          'user_metadata': data['data'] ?? <String, dynamic>{},
        };
        _authUsers.add(user);
        return _session(user);
      case ('GET', 'user'):
      case ('PUT', 'user'):
        final user = _userById(_safeUid(headers));
        if (user == null) {
          return _authError(401, 'no_authorization', 'Not signed in');
        }
        if (method == 'PUT') {
          if (data['password'] != null) user['password'] = data['password'];
          if (data['data'] is Map) {
            user['user_metadata'] = {
              ...?(user['user_metadata'] as Map?)?.cast<String, dynamic>(),
              ...(data['data'] as Map).cast<String, dynamic>(),
            };
          }
          return _Reply.json(_publicUser(user), 200, changed: true);
        }
        return _Reply.json(_publicUser(user), 200);
      case ('POST', 'logout'):
        final uid = _safeUid(headers);
        _refreshTokens.removeWhere((_, owner) => owner == uid);
        return _Reply.empty(204, changed: true);
      case ('POST', 'otp'):
        // Codes aren't sent anywhere; use [otpCode].
        return _Reply.json(<String, dynamic>{}, 200);
      case ('POST', 'verify'):
        final user = _userByEmail(data['email']);
        if (user == null || data['token'] != otpCode) {
          return _authError(
            403,
            'otp_expired',
            'Token has expired or is invalid',
          );
        }
        return _session(user);
      case ('GET', 'health'):
      case ('GET', 'settings'):
        return _Reply.json(<String, dynamic>{}, 200);
    }
    return _authError(
      404,
      'not_found',
      'Not in the dev backend: $method $route',
    );
  }

  /// The one-time code the dev backend accepts, e.g. to delete an account.
  static const otpCode = '123456';

  String? _safeUid(Map<String, String> headers) {
    try {
      return _uid(headers);
    } on _Expired {
      return null;
    }
  }

  // --- rest -----------------------------------------------------------------

  static const _reservedParams = {
    'select',
    'order',
    'limit',
    'offset',
    'on_conflict',
    'columns',
  };

  /// Unique keys besides `id`, as in the Supabase schema.
  static const _uniqueKeys = {
    'user_notifications': ['user_id', 'reference_key'],
  };

  static _Reply _pgError(int status, String code, String message) =>
      _Reply.json({
        'code': code,
        'message': message,
        'details': null,
        'hint': null,
      }, status);

  /// Row-level security: a user only sees and changes their own rows.
  bool _owns(String table, Map<String, dynamic> row, String? uid) {
    if (uid == null) return false;
    if (table == 'users') return row['id'] == uid;
    if (row.containsKey('user_id')) return row['user_id'] == uid;
    if (table == 'batch_records') {
      return _table(
        'daily_records',
      ).any((d) => d['id'] == row['daily_record_id'] && d['user_id'] == uid);
    }
    return true;
  }

  _Reply _rest(
    String method,
    String table,
    Uri url,
    Map<String, String> headers,
    String body,
  ) {
    final String? uid;
    try {
      uid = _uid(headers);
    } on _Expired {
      return _pgError(401, 'PGRST301', 'JWT expired');
    }
    if (!_hasTable(table)) {
      return _pgError(404, '42P01', 'relation "public.$table" does not exist');
    }

    final params = url.queryParametersAll;
    final filters = [
      for (final MapEntry(:key, :value) in params.entries)
        // Filters on embedded resources (`daily_records.user_id`) are
        // ignored: the dev backend doesn't embed.
        if (!_reservedParams.contains(key) && !key.contains('.'))
          for (final v in value) _Filter.parse(key, v),
    ];
    bool matches(Map<String, dynamic> row) =>
        _owns(table, row, uid) && filters.every((f) => f.matches(row));

    final prefer = headers['prefer'] ?? '';
    final returnRows = prefer.contains('return=representation');
    final single = (headers['accept'] ?? '').contains('vnd.pgrst.object');
    final select = params['select']?.firstOrNull;

    _Reply rowsReply(List<Map<String, dynamic>> rows, {int status = 200}) {
      final shaped = [for (final row in rows) _project(row, select)];
      if (!single) return _Reply.json(shaped, status);
      if (shaped.length != 1) {
        return _Reply.json({
          'code': 'PGRST116',
          'details': 'The result contains ${shaped.length} rows',
          'hint': null,
          'message': 'JSON object requested, multiple (or no) rows returned',
        }, 406);
      }
      return _Reply.json(shaped.single, status);
    }

    switch (method) {
      case 'GET':
      case 'HEAD':
        var rows = _table(table).where(matches).toList();
        rows = _order(rows, params['order']?.firstOrNull);
        final offset = int.tryParse(params['offset']?.firstOrNull ?? '') ?? 0;
        final limit = int.tryParse(params['limit']?.firstOrNull ?? '');
        rows = rows.skip(offset).take(limit ?? rows.length).toList();
        return rowsReply(rows);

      case 'POST':
        final decoded = jsonDecode(body);
        final incoming = decoded is List
            ? decoded.cast<Map<String, dynamic>>()
            : [decoded as Map<String, dynamic>];
        final upsert = prefer.contains('resolution=merge-duplicates');
        final ignoreDuplicates = prefer.contains(
          'resolution=ignore-duplicates',
        );
        final conflictColumns =
            params['on_conflict']?.firstOrNull?.split(',') ?? const ['id'];
        final written = <Map<String, dynamic>>[];
        for (final raw in incoming) {
          final row = _withDefaults(table, Map.of(raw));
          if (!_canWrite(table, row, uid)) {
            return _pgError(
              403,
              '42501',
              'new row violates row-level security policy for table "$table"',
            );
          }
          final existing = (upsert || ignoreDuplicates)
              ? _table(table)
                    .where(
                      (r) => conflictColumns.every(
                        (c) => '${r[c]}' == '${row[c]}',
                      ),
                    )
                    .firstOrNull
              : null;
          if (existing != null) {
            if (ignoreDuplicates) continue;
            if (!_owns(table, existing, uid)) {
              return _pgError(
                403,
                '42501',
                'row-level security policy for "$table"',
              );
            }
            final merged = {...existing, ...raw};
            final clash = _uniqueClash(table, merged, except: existing);
            if (clash != null) return clash;
            existing
              ..clear()
              ..addAll(merged);
            written.add(existing);
            continue;
          }
          final clash = _uniqueClash(table, row);
          if (clash != null) return clash;
          _table(table).add(row);
          written.add(row);
        }
        return returnRows
            ? rowsReply(written, status: 201).asChanged()
            : _Reply.empty(201, changed: true);

      case 'PATCH':
        final values = jsonDecode(body) as Map<String, dynamic>;
        final targets = _table(table).where(matches).toList();
        for (final row in targets) {
          final clash = _uniqueClash(table, {...row, ...values}, except: row);
          if (clash != null) return clash;
          row.addAll(values);
        }
        return returnRows
            ? rowsReply(targets).asChanged()
            : _Reply.empty(204, changed: targets.isNotEmpty);

      case 'DELETE':
        final targets = _table(table).where(matches).toList();
        _table(table).removeWhere(targets.contains);
        return returnRows
            ? rowsReply(targets).asChanged()
            : _Reply.empty(204, changed: targets.isNotEmpty);
    }
    return _pgError(405, 'PGRST117', 'Unsupported method $method');
  }

  bool _canWrite(String table, Map<String, dynamic> row, String? uid) {
    if (uid == null) return false;
    if (table == 'users') return row['id'] == uid;
    if (row.containsKey('user_id')) return row['user_id'] == uid;
    return true;
  }

  Map<String, dynamic> _withDefaults(String table, Map<String, dynamic> row) {
    if (row['id'] == null) {
      if (table == 'sale') {
        final sequences = _state['sequences'] as Map<String, dynamic>;
        final next = (sequences['sale'] as int? ?? 0) + 1;
        sequences['sale'] = next;
        row['id'] = next;
      } else {
        row['id'] = _uuid.v4();
      }
    }
    row['created_at'] ??= _now();
    if (table == 'user_notifications') row['is_read'] ??= false;
    return row;
  }

  _Reply? _uniqueClash(
    String table,
    Map<String, dynamic> row, {
    Map<String, dynamic>? except,
  }) {
    final rows = _table(table).where((r) => !identical(r, except));
    final keys = [
      ['id'],
      ?_uniqueKeys[table],
    ];
    for (final key in keys) {
      if (rows.any((r) => key.every((c) => '${r[c]}' == '${row[c]}'))) {
        return _pgError(
          409,
          '23505',
          'duplicate key value violates unique constraint on $table (${key.join(', ')})',
        );
      }
    }
    return null;
  }

  static Map<String, dynamic> _project(
    Map<String, dynamic> row,
    String? select,
  ) {
    if (select == null) return Map.of(row);
    // Top-level columns only; embedded resources (`batches(name)`) and `*`
    // return the whole row.
    final columns = _splitTopLevel(select).map((c) => c.trim()).toList();
    if (columns.any((c) => c == '*' || c.contains('('))) return Map.of(row);
    return {
      for (final column in columns)
        if (row.containsKey(column)) column: row[column],
    };
  }

  static List<String> _splitTopLevel(String select) {
    final parts = <String>[];
    var depth = 0;
    var start = 0;
    for (var i = 0; i < select.length; i++) {
      final ch = select[i];
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (ch == ',' && depth == 0) {
        parts.add(select.substring(start, i));
        start = i + 1;
      }
    }
    parts.add(select.substring(start));
    return parts;
  }

  static List<Map<String, dynamic>> _order(
    List<Map<String, dynamic>> rows,
    String? order,
  ) {
    if (order == null || order.isEmpty) return rows;
    final keys = [
      for (final part in order.split(','))
        (column: part.split('.').first, desc: part.split('.').contains('desc')),
    ];
    return rows.toList()..sort((a, b) {
      for (final (:column, :desc) in keys) {
        final c = _compare(a[column], b[column]);
        if (c != 0) return desc ? -c : c;
      }
      return 0;
    });
  }

  static int _compare(Object? a, Object? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final na = num.tryParse('$a');
    final nb = num.tryParse('$b');
    if (na != null && nb != null) return na.compareTo(nb);
    return '$a'.compareTo('$b');
  }

  // --- database functions ---------------------------------------------------

  _Reply _rpc(String function, Map<String, String> headers, String body) {
    final String? uid;
    try {
      uid = _uid(headers);
    } on _Expired {
      return _pgError(401, 'PGRST301', 'JWT expired');
    }
    final params = body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(body) as Map<String, dynamic>;
    switch (function) {
      case 'get_financial_summary':
        if (uid == null) return _Reply.json(<Object>[], 200);
        return _Reply.json([_financialSummary(uid, params['p_batch_id'])], 200);
      case 'set_recovery_answer':
        final profile = _table(
          'users',
        ).where((u) => u['id'] == uid).firstOrNull;
        profile?['recovery_question'] = params['p_question'];
        profile?['recovery_answer'] = '${params['p_answer']}'
            .trim()
            .toLowerCase();
        return _Reply.json(null, 200, changed: profile != null);
      case 'delete_user_account':
        if (uid == null) return _pgError(401, '42501', 'Not signed in');
        final tables = _state['tables'] as Map<String, dynamic>;
        for (final table in tables.keys) {
          _table(table).removeWhere((row) => _owns(table, row, uid));
        }
        _authUsers.removeWhere((u) => u['id'] == uid);
        _refreshTokens.removeWhere((_, owner) => owner == uid);
        return _Reply.json(null, 200, changed: true);
    }
    return _pgError(
      404,
      'PGRST202',
      'Could not find the function public.$function in the dev backend',
    );
  }

  /// A rough version of the server's summary, enough to work on the screen.
  Map<String, dynamic> _financialSummary(String uid, Object? batchId) {
    double sum(
      Iterable<Map<String, dynamic>> rows,
      num Function(Map<String, dynamic>) f,
    ) => rows.fold(0.0, (total, row) => total + f(row).toDouble());
    num n(Object? v) => v is num ? v : num.tryParse('$v') ?? 0;
    double pct(double part, double whole) =>
        whole == 0 ? 0 : double.parse((part / whole * 100).toStringAsFixed(1));

    final sales = _table('sale').where((s) => s['user_id'] == uid);
    double salesOf(String type) =>
        sum(sales.where((s) => s['sale_type'] == type), (s) => n(s['amount']));
    final chicken = salesOf('chicken');
    final eggs = salesOf('eggs');
    final manure = salesOf('manure');
    final totalSales = chicken + eggs + manure;

    final batches = _table('batches').where(
      (b) => b['user_id'] == uid && (batchId == null || b['id'] == batchId),
    );
    final items = _table('inventory_items').where((i) => i['user_id'] == uid);
    double stockOf(String category) => sum(
      items.where((i) => i['category'] == category),
      (i) => n(i['price']) * n(i['quantity']),
    );
    final feed = stockOf('feeds');
    final vaccine = stockOf('medicines');
    final other =
        stockOf('others') + sum(batches, (b) => n(b['purchase_cost']));
    final totalExpenses = feed + vaccine + other;

    final batchIds = batches.map((b) => b['id']).toSet();
    final died = sum(
      _table('batch_records').where((r) => batchIds.contains(r['batch_id'])),
      (r) => n(r['chickens_died']),
    );
    final birds = sum(batches, (b) => n(b['initial_count']));
    final single = batchId == null ? null : batches.firstOrNull;

    return {
      'batch_id': single?['id'],
      'batch_name': single?['name'],
      'total_sales': totalSales,
      'total_expenses': totalExpenses,
      'profit': totalSales - totalExpenses,
      'eggs_sales': eggs,
      'chicken_sales': chicken,
      'manure_sales': manure,
      'eggs_sales_pct': pct(eggs, totalSales),
      'chicken_sales_pct': pct(chicken, totalSales),
      'manure_sales_pct': pct(manure, totalSales),
      'feed_expense': feed,
      'vaccine_expense': vaccine,
      'other_expense': other,
      'feeds_expense_pct': pct(feed, totalExpenses),
      'vaccines_expense_pct': pct(vaccine, totalExpenses),
      'other_expense_pct': pct(other, totalExpenses),
      'predicted_revenue': null,
      'store_inventory_value': feed + vaccine + stockOf('others'),
      'mortality_rate': pct(died, birds),
      'fcr': 0,
    };
  }
}

class _Expired implements Exception {
  const _Expired();
}

/// One PostgREST filter, such as `user_id=eq.abc` or `id=in.("a","b")`.
class _Filter {
  _Filter(this.column, this.op, this.arg);

  factory _Filter.parse(String column, String value) {
    final dot = value.indexOf('.');
    if (dot < 0) return _Filter(column, 'eq', value);
    return _Filter(column, value.substring(0, dot), value.substring(dot + 1));
  }

  final String column;
  final String op;
  final String arg;

  static String _text(Object? v) => v == null ? 'null' : '$v';

  bool matches(Map<String, dynamic> row) {
    final value = row[column];
    switch (op) {
      case 'eq':
        return _text(value) == arg;
      case 'neq':
        return _text(value) != arg;
      case 'is':
        return switch (arg) {
          'null' => value == null,
          'true' => value == true,
          'false' => value == false,
          _ => false,
        };
      case 'in':
        final inner = arg.startsWith('(') && arg.endsWith(')')
            ? arg.substring(1, arg.length - 1)
            : arg;
        final options = inner.isEmpty
            ? const <String>[]
            : inner.split(',').map((o) => o.trim().replaceAll('"', ''));
        return options.contains(_text(value));
      case 'gt':
        return value != null && DevBackend._compare(value, arg) > 0;
      case 'gte':
        return value != null && DevBackend._compare(value, arg) >= 0;
      case 'lt':
        return value != null && DevBackend._compare(value, arg) < 0;
      case 'lte':
        return value != null && DevBackend._compare(value, arg) <= 0;
      case 'like':
      case 'ilike':
        final pattern = RegExp(
          '^${RegExp.escape(arg).replaceAll(r'\*', '.*').replaceAll('%', '.*')}\$',
          caseSensitive: op == 'like',
        );
        return pattern.hasMatch(_text(value));
    }
    // Unknown operators don't filter rather than hide everything.
    return true;
  }
}

class _Reply {
  const _Reply(this.status, this.body, {this.changed = false});

  factory _Reply.json(Object? data, int status, {bool changed = false}) =>
      _Reply(status, jsonEncode(data), changed: changed);

  factory _Reply.empty(int status, {bool changed = false}) =>
      _Reply(status, '', changed: changed);

  final int status;
  final String body;

  /// Whether the request changed the data, so it is saved.
  final bool changed;

  _Reply asChanged() => _Reply(status, body, changed: true);
}

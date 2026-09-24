import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const fakeUserId = '11111111-1111-1111-1111-111111111111';

typedef Responder = Future<http.Response> Function(http.Request request);

/// An in-memory stand-in for the Supabase HTTP API.
///
/// The real [SupabaseClient] is initialised against this backend, so the
/// providers under test run unmodified. Register responses with [on] and
/// inspect what was sent through [requests].
class FakeSupabaseBackend {
  final List<http.Request> requests = [];
  final Map<String, Responder> _routes = {};

  late final http.Client client = MockClient((request) async {
    requests.add(request);
    final responder = _routes['${request.method} ${request.url.path}'];
    final response = responder == null
        ? json({
            'message':
                'No fake route for ${request.method} ${request.url.path}',
          }, status: 404)
        : await responder(request);
    // postgrest reads `response.request`, which MockClient leaves unset.
    return http.Response.bytes(
      response.bodyBytes,
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  });

  /// Responds to [method] requests on [path], e.g. `on('GET', '/rest/v1/batches', ...)`.
  void on(String method, String path, Responder respond) {
    _routes['$method $path'] = respond;
  }

  /// Requests sent to [path], optionally filtered by [method].
  List<http.Request> requestsTo(String path, {String? method}) => requests
      .where(
        (r) => r.url.path == path && (method == null || r.method == method),
      )
      .toList();

  void reset() {
    requests.clear();
    _routes.clear();
    on('POST', '/auth/v1/logout', (_) async => http.Response('', 204));
  }

  static http.Response json(Object? body, {int status = 200}) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

/// A user payload in the shape GoTrue returns.
Map<String, dynamic> fakeUser({
  String id = fakeUserId,
  Map<String, dynamic> metadata = const {},
}) => {
  'id': id,
  'aud': 'authenticated',
  'role': 'authenticated',
  'email': 'farmer@ikuku.test',
  'app_metadata': {'provider': 'email'},
  'user_metadata': metadata,
  'created_at': '2025-01-01T00:00:00Z',
};

/// A session payload in the shape GoTrue returns from sign-in and sign-up.
Map<String, dynamic> fakeSession({
  String userId = fakeUserId,
  Map<String, dynamic> metadata = const {},
}) {
  final exp = DateTime.now().add(const Duration(hours: 1));
  String encode(Map<String, dynamic> part) =>
      base64Url.encode(utf8.encode(jsonEncode(part))).replaceAll('=', '');
  final token = [
    encode({'alg': 'HS256', 'typ': 'JWT'}),
    encode({
      'sub': userId,
      'role': 'authenticated',
      'exp': exp.millisecondsSinceEpoch ~/ 1000,
    }),
    'signature',
  ].join('.');
  return {
    'access_token': token,
    'token_type': 'bearer',
    'expires_in': 3600,
    'expires_at': exp.millisecondsSinceEpoch ~/ 1000,
    'refresh_token': 'refresh-token',
    'user': fakeUser(id: userId, metadata: metadata),
  };
}

/// Initialises the global [Supabase] instance against [backend].
///
/// Call once per test file from `setUpAll`; Supabase is a singleton.
Future<void> initFakeSupabase(FakeSupabaseBackend backend) async {
  SharedPreferences.setMockInitialValues({});
  backend.reset();
  await Supabase.initialize(
    url: 'https://fake.supabase.test',
    anonKey: 'fake-anon-key',
    httpClient: backend.client,
    debug: false,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: false,
      detectSessionInUri: false,
      localStorage: EmptyLocalStorage(),
    ),
  );
}

/// Signs the fake user in through the real auth client.
Future<void> signInFakeUser(FakeSupabaseBackend backend) async {
  backend.on(
    'POST',
    '/auth/v1/token',
    (_) async => FakeSupabaseBackend.json(fakeSession()),
  );
  await Supabase.instance.client.auth.signInWithPassword(
    email: 'farmer@ikuku.test',
    password: 'secret1',
  );
  backend.requests.clear();
}

Future<void> signOutFakeUser() async {
  if (Supabase.instance.client.auth.currentUser != null) {
    await Supabase.instance.client.auth.signOut();
  }
}

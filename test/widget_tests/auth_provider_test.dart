import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:ikuku/routing/app_router.dart';

import '../helpers/fake_supabase.dart';

const usersPath = '/rest/v1/users';
const farmsPath = '/rest/v1/farms';

void main() {
  final backend = FakeSupabaseBackend();
  late GoRouter router;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initFakeSupabase(backend);
  });

  setUp(() {
    backend.reset();
    // testConnection probes the users table.
    backend.on('GET', usersPath, (_) async => FakeSupabaseBackend.json([]));
  });
  tearDown(signOutFakeUser);

  /// Mounts a router on the app's [navigatorKey], which AuthProvider reads
  /// when it is created, and returns a fresh provider.
  Future<AuthProvider> pumpAuth(WidgetTester tester) async {
    router = GoRouter(
      navigatorKey: navigatorKey,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(path: '/login', builder: (_, _) => const Text('login')),
        GoRoute(
          path: '/create-farm',
          builder: (_, state) => Text('create-farm ${state.extra ?? ''}'),
        ),
      ],
      initialLocation: '/login',
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    return AuthProvider();
  }

  String location() => router.routerDelegate.currentConfiguration.uri.path;

  /// Runs [action] with real async IO so the fake HTTP calls complete.
  Future<void> run(WidgetTester tester, Future<void> Function() action) async {
    await tester.runAsync(action);
    await tester.pumpAndSettle();
  }

  testWidgets('starts in sign-up mode and toggles', (tester) async {
    final provider = await pumpAuth(tester);
    expect(provider.isSignUp, isTrue);
    expect(provider.isLoading, isFalse);

    provider.toggleAuthState();
    expect(provider.isSignUp, isFalse);
    expect(provider.errorMessage, isNull);
  });

  group('register', () {
    testWidgets('rejects mismatched passwords without calling Supabase', (
      tester,
    ) async {
      final provider = await pumpAuth(tester);
      await run(tester, () => provider.register('a@b.co', 'secret1', 'other'));

      expect(provider.errorMessage, 'Passwords do not match');
      expect(provider.isLoading, isFalse);
      expect(backend.requests, isEmpty);
    });

    testWidgets('signs up, creates the user row and goes to create-farm', (
      tester,
    ) async {
      backend.on(
        'POST',
        '/auth/v1/signup',
        (_) async => FakeSupabaseBackend.json(fakeSession()),
      );
      backend.on(
        'POST',
        usersPath,
        (_) async => FakeSupabaseBackend.json(null, status: 201),
      );
      final provider = await pumpAuth(tester);

      await run(
        tester,
        () => provider.register('a@b.co', 'secret1', 'secret1'),
      );

      final signup = backend.requestsTo('/auth/v1/signup').single;
      expect(jsonDecode(signup.body), containsPair('email', 'a@b.co'));
      final insert = backend.requestsTo(usersPath, method: 'POST').single;
      expect(jsonDecode(insert.body), {
        'id': fakeUserId,
        'full_name': '',
        'phone_number': '',
      });
      expect(location(), '/create-farm');
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse);
    });

    testWidgets('still goes to create-farm if the user row insert fails', (
      tester,
    ) async {
      backend.on(
        'POST',
        '/auth/v1/signup',
        (_) async => FakeSupabaseBackend.json(fakeSession()),
      );
      backend.on(
        'POST',
        usersPath,
        (_) async =>
            FakeSupabaseBackend.json({'message': 'duplicate'}, status: 409),
      );
      final provider = await pumpAuth(tester);

      await run(
        tester,
        () => provider.register('a@b.co', 'secret1', 'secret1'),
      );

      expect(location(), '/create-farm');
      expect(provider.errorMessage, isNull);
    });

    testWidgets('maps "User already registered" to a friendly message', (
      tester,
    ) async {
      backend.on(
        'POST',
        '/auth/v1/signup',
        (_) async => FakeSupabaseBackend.json({
          'code': 422,
          'error_code': 'user_already_exists',
          'msg': 'User already registered',
        }, status: 422),
      );
      final provider = await pumpAuth(tester);

      await run(
        tester,
        () => provider.register('a@b.co', 'secret1', 'secret1'),
      );

      expect(provider.errorMessage, 'user_already_registered');
      expect(location(), '/login');
      expect(provider.isLoading, isFalse);
    });
  });

  group('login', () {
    void signInSucceeds({Map<String, dynamic> metadata = const {}}) {
      backend.on(
        'POST',
        '/auth/v1/token',
        (_) async => FakeSupabaseBackend.json(fakeSession(metadata: metadata)),
      );
    }

    testWidgets('goes home when the user has a farm', (tester) async {
      signInSucceeds();
      backend.on(
        'GET',
        usersPath,
        (_) async => FakeSupabaseBackend.json({'id': fakeUserId}),
      );
      backend.on(
        'GET',
        farmsPath,
        (_) async =>
            FakeSupabaseBackend.json({'id': 'f1', 'user_id': fakeUserId}),
      );
      final provider = await pumpAuth(tester);

      await run(tester, () => provider.login('a@b.co', 'secret1'));

      final token = backend.requestsTo('/auth/v1/token').single;
      expect(token.url.queryParameters['grant_type'], 'password');
      expect(backend.requestsTo(usersPath, method: 'POST'), isEmpty);
      expect(
        backend.requestsTo(farmsPath).single.url.queryParameters['user_id'],
        'eq.$fakeUserId',
      );
      expect(location(), '/');
      expect(provider.errorMessage, isNull);
    });

    testWidgets('creates a missing user row and sends farmers without a farm to '
        'create-farm with their details', (tester) async {
      signInSucceeds(
        metadata: {'full_name': 'Jane', 'phone_number': '0712345678'},
      );
      backend.on(
        'GET',
        usersPath,
        (request) async =>
            // testConnection selects `count`; the existence check selects `id`.
            request.url.queryParameters['select'] == 'id'
            ? FakeSupabaseBackend.json(null)
            : FakeSupabaseBackend.json([]),
      );
      backend.on(
        'POST',
        usersPath,
        (_) async => FakeSupabaseBackend.json(null, status: 201),
      );
      backend.on('GET', farmsPath, (_) async => FakeSupabaseBackend.json(null));
      final provider = await pumpAuth(tester);

      await run(tester, () => provider.login('a@b.co', 'secret1'));

      final insert = backend.requestsTo(usersPath, method: 'POST').single;
      expect(jsonDecode(insert.body), {
        'id': fakeUserId,
        'full_name': 'Jane',
        'phone_number': '0712345678',
      });
      expect(location(), '/create-farm');
      expect(
        find.text('create-farm {name: Jane, phone: 0712345678}'),
        findsOneWidget,
      );
    });

    for (final (description, status, body, expected) in [
      (
        'invalid credentials',
        400,
        {
          'error': 'invalid_grant',
          'error_description': 'Invalid login credentials',
        },
        'invalid_email_or_password',
      ),
      (
        'unconfirmed email',
        400,
        {'error_code': 'email_not_confirmed', 'msg': 'Email not confirmed'},
        'email_not_confirmed',
      ),
      (
        'bad API key',
        401,
        {'message': 'Invalid API key'},
        'configuration_error',
      ),
      (
        'unexpected errors',
        500,
        {'message': 'Database: exploded'},
        'an_error_occurred',
      ),
    ]) {
      testWidgets('maps $description to "$expected"', (tester) async {
        backend.on(
          'POST',
          '/auth/v1/token',
          (_) async => FakeSupabaseBackend.json(body, status: status),
        );
        final provider = await pumpAuth(tester);

        await run(tester, () => provider.login('a@b.co', 'wrong'));

        expect(provider.errorMessage, expected);
        expect(provider.isLoading, isFalse);
        expect(location(), '/login');
      });
    }

    testWidgets('maps network failures to "no_internet_connection"', (
      tester,
    ) async {
      backend.on(
        'POST',
        '/auth/v1/token',
        (_) async => throw const SocketException(
          'Failed host lookup: fake.supabase.test',
        ),
      );
      final provider = await pumpAuth(tester);

      await run(tester, () => provider.login('a@b.co', 'secret1'));

      expect(provider.errorMessage, 'no_internet_connection');
      expect(location(), '/login');
    });

    testWidgets('sets loading while the request is in flight', (tester) async {
      signInSucceeds();
      backend.on(
        'GET',
        farmsPath,
        (_) async => FakeSupabaseBackend.json({'id': 'f1'}),
      );
      final provider = await pumpAuth(tester);
      final loadingStates = <bool>[];
      provider.addListener(() => loadingStates.add(provider.isLoading));

      await run(tester, () => provider.login('a@b.co', 'secret1'));

      expect(loadingStates.first, isTrue);
      expect(loadingStates.last, isFalse);
    });
  });

  testWidgets('internetTest reports a successful connection', (tester) async {
    final provider = await pumpAuth(tester);

    await run(tester, provider.internetTest);

    expect(provider.errorMessage, 'connection_test_successful');
    expect(provider.isLoading, isFalse);
  });
}

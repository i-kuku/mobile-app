import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ikuku/shared/services/supabase_service.dart';

import '../helpers/fake_supabase.dart';

const usersPath = '/rest/v1/users';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final backend = FakeSupabaseBackend();

  setUpAll(() => initFakeSupabase(backend));
  setUp(backend.reset);

  group('testConnection', () {
    test('is true when the probe query succeeds', () async {
      backend.on(
        'GET',
        usersPath,
        (_) async => FakeSupabaseBackend.json([
          {'count': 3},
        ]),
      );

      expect(await SupabaseService().testConnection(), isTrue);
      expect(
        backend.requestsTo(usersPath).single.url.queryParameters,
        containsPair('select', 'count'),
      );
    });

    for (final (reason, status) in [
      ('permission denied', 401),
      ('missing table', 404),
      ('server error', 500),
    ]) {
      test('is true when the server answers with an error ($reason)', () async {
        backend.on(
          'GET',
          usersPath,
          (_) async =>
              FakeSupabaseBackend.json({'message': reason}, status: status),
        );

        expect(await SupabaseService().testConnection(), isTrue);
      });
    }

    test('is false when the device is offline', () async {
      backend.on(
        'GET',
        usersPath,
        (_) async => throw const SocketException(
          'Failed host lookup: fake.supabase.test',
        ),
      );

      expect(await SupabaseService().testConnection(), isFalse);
    });

    test('is false when the HTTP client fails', () async {
      backend.on(
        'GET',
        usersPath,
        (_) async => throw http.ClientException('Connection closed'),
      );

      expect(await SupabaseService().testConnection(), isFalse);
    });
  });
}

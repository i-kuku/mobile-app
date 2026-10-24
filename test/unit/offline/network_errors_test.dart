import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ikuku/shared/offline/network_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('classifyFailure', () {
    for (final (description, error) in <(String, Object)>[
      ('a timeout', TimeoutException('slow')),
      ('a socket error', const SocketException('Failed host lookup')),
      ('an http client error', http.ClientException('Connection reset')),
      (
        'gotrue failing to fetch',
        AuthRetryableFetchException(message: 'SocketException: no route'),
      ),
      (
        'a captive portal answering for the server',
        const PostgrestException(message: '<html>', code: '200'),
      ),
      (
        'a connection reset mid-request',
        Exception('Connection closed before full header was received'),
      ),
      (
        'a TLS handshake failure',
        Exception('HandshakeException: Connection terminated during handshake'),
      ),
      ('the browser failing to fetch', Exception('XMLHttpRequest error.')),
      (
        'a storage upload without a status',
        const StorageException('ClientException: Software caused abort'),
      ),
    ]) {
      test('treats $description as a network failure', () {
        expect(classifyFailure(error), FailureKind.network);
        expect(isNetworkError(error), isTrue);
      });
    }

    for (final (description, error) in <(String, Object)>[
      ('a 500', const PostgrestException(message: 'boom', code: '500')),
      ('a 503', const PostgrestException(message: 'busy', code: '503')),
      ('a 429', const PostgrestException(message: 'slow down', code: '429')),
      (
        'a statement timeout',
        const PostgrestException(message: 'canceled', code: '57014'),
      ),
      (
        'gotrue answering 502',
        AuthRetryableFetchException(message: 'bad gateway', statusCode: '502'),
      ),
    ]) {
      test('treats $description as transient', () {
        expect(classifyFailure(error), FailureKind.transient);
      });
    }

    for (final (description, error) in <(String, Object)>[
      (
        'an expired JWT',
        const PostgrestException(message: 'JWT expired', code: 'PGRST301'),
      ),
      ('a 401', const PostgrestException(message: 'no', code: '401')),
      ('a missing session', AuthSessionMissingException()),
    ]) {
      test('treats $description as an auth problem', () {
        expect(classifyFailure(error), FailureKind.auth);
      });
    }

    for (final (description, error) in <(String, Object)>[
      (
        'a unique violation',
        const PostgrestException(message: 'dup', code: '23505'),
      ),
      (
        'an RLS refusal',
        const PostgrestException(message: 'no', code: '42501'),
      ),
      ('a 403', const PostgrestException(message: 'denied', code: '403')),
      (
        'wrong credentials',
        const AuthApiException('Invalid login credentials', statusCode: '400'),
      ),
      ('anything else', StateError('bug')),
      (
        'a full disk',
        Exception(
          'FileSystemException: Cannot open file, path = /x.jpg '
          '(OS Error: No space left on device, errno = 28)',
        ),
      ),
    ]) {
      test('treats $description as rejected', () {
        expect(classifyFailure(error), FailureKind.rejected);
      });
    }
  });

  test('isDuplicateRow spots unique violations only', () {
    expect(
      isDuplicateRow(const PostgrestException(message: 'd', code: '23505')),
      isTrue,
    );
    expect(
      isDuplicateRow(const PostgrestException(message: 'd', code: '23503')),
      isFalse,
    );
  });

  test('friendlyErrorMessage never repeats the raw error', () {
    const raw =
        'ClientException with SocketException: Failed host lookup: '
        "'abc.supabase.co' (OS Error: No address associated with hostname, "
        'errno = 7), uri=https://abc.supabase.co/rest/v1/users';
    final message = friendlyErrorMessage(Exception(raw));
    expect(message, 'needs_internet_message');
    expect(
      friendlyErrorMessage(const PostgrestException(message: 'x', code: '500')),
      'server_busy_message',
    );
    expect(
      friendlyErrorMessage(StateError('bug')),
      'something_went_wrong_message',
    );
  });
}

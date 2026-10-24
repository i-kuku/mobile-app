import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Why a request to the server failed, which decides what to do next.
enum FailureKind {
  /// The request never reached the server: no connection, DNS, TLS, a
  /// captive portal or a timeout. Keep the work and try again later.
  network,

  /// The session is missing or expired. Refresh it, then try again.
  auth,

  /// The server failed in a way that usually passes (5xx, 429, overload).
  transient,

  /// The server rejected the request. Sending it again unchanged won't help.
  rejected,
}

// Fragments of the messages dart:io, the browser and package:http produce
// when a request can't reach the server. Matched on text so this file stays
// usable on the web, where dart:io types don't exist.
const _networkMessageFragments = [
  'socketexception',
  'clientexception',
  'failed host lookup',
  'no address associated with hostname',
  'nodename nor servname',
  'network is unreachable',
  'connection refused',
  'connection reset',
  'connection closed',
  'connection aborted',
  'connection timed out',
  'connection terminated',
  'software caused connection abort',
  'broken pipe',
  'handshakeexception',
  'certificate_verify_failed',
  'xmlhttprequest error',
  'failed to fetch',
  'os error',
];

bool _looksLikeNetworkFailure(String message) {
  final lower = message.toLowerCase();
  return _networkMessageFragments.any(lower.contains);
}

/// Sorts [error] from any Supabase or HTTP call into a [FailureKind].
FailureKind classifyFailure(Object error) {
  if (error is TimeoutException) return FailureKind.network;
  if (error is http.ClientException) return FailureKind.network;

  if (error is AuthRetryableFetchException) {
    // gotrue raises this both for requests that never arrived (no status)
    // and for 5xx answers.
    return error.statusCode == null
        ? FailureKind.network
        : FailureKind.transient;
  }
  if (error is AuthSessionMissingException) return FailureKind.auth;
  if (error is AuthException) {
    final status = int.tryParse(error.statusCode ?? '');
    if (status != null && status >= 500) return FailureKind.transient;
    if (status == 429) return FailureKind.transient;
    if (_looksLikeNetworkFailure(error.message)) return FailureKind.network;
    return FailureKind.rejected;
  }

  if (error is PostgrestException) return _classifyPostgrest(error);

  if (error is StorageException) {
    final status = int.tryParse(error.statusCode ?? '');
    if (status == null) {
      return _looksLikeNetworkFailure(error.message)
          ? FailureKind.network
          : FailureKind.rejected;
    }
    return _classifyStatus(status);
  }

  if (_looksLikeNetworkFailure(error.toString())) return FailureKind.network;
  return FailureKind.rejected;
}

FailureKind _classifyPostgrest(PostgrestException error) {
  final code = error.code ?? '';
  // postgrest falls back to the HTTP status when the body has no code.
  // Postgres codes are five characters, and can be all digits (23505).
  final status = code.length == 3 ? int.tryParse(code) : null;
  if (status != null) return _classifyStatus(status);

  // PGRST3xx are JWT problems, e.g. PGRST301 "JWT expired".
  if (code.startsWith('PGRST3')) return FailureKind.auth;
  // Postgres connection (08), resource (53) and operator-intervention (57)
  // errors, plus serialization failures and deadlocks, are worth retrying.
  if (code.startsWith('08') ||
      code.startsWith('53') ||
      code.startsWith('57') ||
      code == '40001' ||
      code == '40P01') {
    return FailureKind.transient;
  }
  return FailureKind.rejected;
}

FailureKind _classifyStatus(int status) {
  // A success or redirect status on an error means something between us and
  // the server answered instead, such as a captive portal's login page.
  if (status < 400) return FailureKind.network;
  if (status == 401) return FailureKind.auth;
  if (status == 408 || status == 429 || status >= 500) {
    return FailureKind.transient;
  }
  return FailureKind.rejected;
}

/// Whether [error] means the server couldn't be reached at all.
bool isNetworkError(Object error) =>
    classifyFailure(error) == FailureKind.network;

/// Whether [error] is a Postgres unique violation, i.e. the row is already
/// on the server.
bool isDuplicateRow(Object error) =>
    error is PostgrestException && error.code == '23505';

/// A short message for [error] that is safe to show a farmer. Raw exception
/// text never reaches the screen.
String friendlyErrorMessage(Object error) {
  switch (classifyFailure(error)) {
    case FailureKind.network:
      return 'needs_internet_message'.tr();
    case FailureKind.transient:
      return 'server_busy_message'.tr();
    case FailureKind.auth:
      return 'session_expired_message'.tr();
    case FailureKind.rejected:
      return 'something_went_wrong_message'.tr();
  }
}

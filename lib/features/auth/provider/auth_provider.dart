import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/auth/data/pending_registration.dart';
import 'package:ikuku/routing/app_router.dart';
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:ikuku/shared/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// How far finishing a sign-up started offline has got.
enum PendingSignUpStatus {
  idle,

  /// Talking to the server.
  working,

  /// Offline; it is tried again when the connection returns.
  waitingForNetwork,

  /// The app was closed in between, so the password must be typed again.
  needsPassword,

  /// The account was made but its email must be confirmed before signing in.
  confirmEmail,

  /// The email already has an account with a different password.
  accountExists,

  /// Something else went wrong; see [AuthProvider.errorMessage].
  failed,
}

class AuthProvider with ChangeNotifier {
  AuthProvider({this.requestTimeout = const Duration(seconds: 20)});

  /// How long to wait for Supabase auth and profile requests before
  /// reporting a timeout.
  final Duration requestTimeout;

  bool _isLoading = false;

  String? _errorMessage;
  bool _isConnectionError = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Whether [errorMessage] is about connectivity, so the UI can offer a
  /// connection test regardless of the display language.
  bool get isConnectionError => _isConnectionError;

  void _setError(String? message, {bool isConnectionError = false}) {
    _errorMessage = message;
    _isConnectionError = isConnectionError;
  }

  bool _isSignUp = true;

  bool get isSignUp => _isSignUp;

  // Kept in memory only, never on disk. If the app is closed before the
  // account is made, the farmer types it again.
  String? _pendingPassword;
  PendingSignUpStatus _pendingStatus = PendingSignUpStatus.idle;

  PendingSignUpStatus get pendingSignUpStatus => _pendingStatus;

  void _setPendingStatus(PendingSignUpStatus status) {
    _pendingStatus = status;
    notifyListeners();
  }

  GoTrueClient get _auth => Supabase.instance.client.auth;

  OfflineServices? get _offline =>
      OfflineServices.isReady ? OfflineServices.instance : null;

  /// Navigates via the app navigator, if it is mounted. Looked up on use
  /// rather than stored, so creating the provider before the navigator
  /// exists is safe.
  void _go(String location, {Object? extra}) {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.go(location, extra: extra);
    }
  }

  void toggleAuthState() {
    _isSignUp = !_isSignUp;
    _setError(null);
    notifyListeners();
  }

  /// Switches the auth page to signing in, e.g. after an offline sign-up
  /// turned out to need email confirmation.
  void showSignIn() {
    _isSignUp = false;
    _setError(null);
    notifyListeners();
  }

  Future<void> register(String email, String password, String cPassword) async {
    _setError(null);
    _isLoading = true;
    notifyListeners();

    try {
      if (cPassword != password) {
        _setError("Passwords do not match");
        return;
      }

      final res = await _auth
          .signUp(email: email, password: password)
          .timeout(requestTimeout);
      final user = res.user;
      debugPrint(
        'Sign up response: ${res.session != null ? 'Session created' : 'No session'}',
      );
      if (user == null) {
        _setError('sign_up_failed'.tr());
        return;
      }
      if (res.session == null) {
        // The email must be confirmed before signing in. Collect the farm
        // details meanwhile; they're sent after the first sign-in.
        await _keepPendingRegistration(email);
        _pendingPassword = password;
        _pendingStatus = PendingSignUpStatus.confirmEmail;
        _go('/create-farm');
        return;
      }

      await PendingRegistrationStore.clear();
      await _offline?.signedIn(user.id);
      try {
        await Supabase.instance.client
            .from('users')
            .insert({'id': user.id, 'full_name': '', 'phone_number': ''})
            .timeout(requestTimeout);
        debugPrint('User record created successfully');
      } catch (dbError) {
        // Creating the farm saves the profile row too.
        debugPrint('Database error creating user record: $dbError');
      }
      _go('/create-farm');
    } catch (e) {
      if (isNetworkError(e)) {
        // The account needs the server, but the rest of sign-up doesn't:
        // keep going and create the account once there's a connection.
        await _keepPendingRegistration(email);
        _pendingPassword = password;
        _pendingStatus = PendingSignUpStatus.waitingForNetwork;
        _go('/create-farm');
      } else {
        _setErrorFrom(e);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves [email] as the pending sign-up, keeping any farm details already
  /// collected for an earlier attempt.
  Future<void> _keepPendingRegistration(String email) async {
    final existing = await PendingRegistrationStore.load();
    await PendingRegistrationStore.save(
      existing?.withEmail(email) ?? PendingRegistration(email: email),
    );
  }

  /// Creates the account for a sign-up started offline, then queues the
  /// farm details collected meanwhile. Safe to call again and again, e.g.
  /// each time the connection returns.
  Future<void> completePendingRegistration({String? password}) async {
    if (_pendingStatus == PendingSignUpStatus.working) return;
    final pending = await PendingRegistrationStore.load();
    if (pending == null) {
      _go('/auth');
      return;
    }
    if (password != null) _pendingPassword = password;
    final secret = _pendingPassword;
    if (secret == null) {
      _setPendingStatus(PendingSignUpStatus.needsPassword);
      return;
    }

    _setError(null);
    _setPendingStatus(PendingSignUpStatus.working);
    try {
      AuthResponse res;
      try {
        res = await _auth
            .signUp(email: pending.email, password: secret)
            .timeout(requestTimeout);
      } on AuthException catch (e) {
        if (!_isAlreadyRegistered(e)) rethrow;
        // An earlier attempt may have made the account before the
        // connection dropped, so try signing in with the same details.
        try {
          res = await _auth
              .signInWithPassword(email: pending.email, password: secret)
              .timeout(requestTimeout);
        } on AuthException catch (e) {
          if (isNetworkError(e)) rethrow;
          if (e.message.contains('Email not confirmed')) {
            _setPendingStatus(PendingSignUpStatus.confirmEmail);
          } else {
            _pendingPassword = null;
            _setPendingStatus(PendingSignUpStatus.accountExists);
          }
          return;
        }
      }

      final user = res.user;
      if (user == null) {
        _setError('sign_up_failed'.tr());
        _setPendingStatus(PendingSignUpStatus.failed);
        return;
      }
      if (res.session == null) {
        _setPendingStatus(PendingSignUpStatus.confirmEmail);
        return;
      }

      await _offline?.signedIn(user.id);
      await _applyPendingRegistration(user.id, pending);
      _setPendingStatus(PendingSignUpStatus.idle);
      _go(pending.hasFarmDetails ? '/' : '/create-farm');
    } catch (e) {
      if (isNetworkError(e)) {
        _setPendingStatus(PendingSignUpStatus.waitingForNetwork);
      } else {
        _setErrorFrom(e);
        _setPendingStatus(PendingSignUpStatus.failed);
      }
    }
  }

  bool _isAlreadyRegistered(AuthException e) =>
      e.code == 'user_already_exists' ||
      e.message.contains('User already registered');

  /// Queues what was collected during an offline sign-up for [userId], then
  /// forgets the draft.
  Future<void> _applyPendingRegistration(
    String userId,
    PendingRegistration pending,
  ) async {
    final sync = _offline?.sync;
    if (sync != null) {
      if (pending.fullName != null || pending.phone != null) {
        await sync.mergeRow(LocalTables.users, {
          'id': userId,
          'full_name': pending.fullName ?? '',
          'phone_number': pending.phone ?? '',
        });
      }
      if (pending.hasFarmDetails) {
        await sync.insertRow(LocalTables.farms, {
          'user_id': userId,
          'farm_name': pending.farmName,
          'farm_location': pending.farmLocation,
        });
      }
      if (pending.hasRecovery) {
        await sync.queueUpdate(
          LocalTables.users,
          recordId: userId,
          values: {
            'recovery_question': pending.recoveryQuestion,
            'recovery_answer': pending.recoveryAnswer!.trim().toLowerCase(),
          },
          match: {'id': userId},
        );
      }
    }
    await PendingRegistrationStore.clear();
    _pendingPassword = null;
  }

  Future<void> login(String email, String password) async {
    _setError(null);
    _isLoading = true;

    notifyListeners();
    try {
      debugPrint('Attempting sign in for email: $email');
      final res = await _auth
          .signInWithPassword(email: email, password: password)
          .timeout(requestTimeout);
      debugPrint(
        'Sign in response: ${res.session != null ? 'Session created' : 'No session'}',
      );

      final user = res.user;
      if (user == null) {
        _setError('sign_in_failed'.tr());
        return;
      }
      await _offline?.signedIn(user.id);

      final pending = await PendingRegistrationStore.load();
      if (pending != null) {
        if (pending.email.toLowerCase() == email.toLowerCase()) {
          // Finishing a sign-up whose email needed confirming first.
          await _applyPendingRegistration(user.id, pending);
          _go(pending.hasFarmDetails ? '/' : '/create-farm');
          return;
        }
        // Signing in with another account abandons that sign-up, which
        // would otherwise keep redirecting signed-out sessions to it.
        await PendingRegistrationStore.clear();
        _pendingPassword = null;
        _pendingStatus = PendingSignUpStatus.idle;
      }

      final (location, extra) = await _destinationAfterSignIn(user);
      _go(location, extra: extra);
    } catch (e) {
      _setErrorFrom(e, signingIn: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Where to go once [user] has signed in: setting up a farm, or home.
  ///
  /// Signing in is the only step that needs the server. If it can't be
  /// reached for these checks, carry on home; the farm comes down with the
  /// next sync.
  Future<(String, Object?)> _destinationAfterSignIn(User user) async {
    final client = Supabase.instance.client;
    try {
      final userExists = await client
          .from('users')
          .select('id')
          .eq('id', user.id)
          .maybeSingle()
          .timeout(requestTimeout);
      if (userExists == null) {
        debugPrint('Creating user record for existing auth user');
        await client
            .from('users')
            .insert({
              'id': user.id,
              'full_name': user.userMetadata?['full_name'] ?? '',
              'phone_number': user.userMetadata?['phone_number'] ?? '',
            })
            .timeout(requestTimeout);
      }
    } catch (dbError) {
      debugPrint('Database error checking/creating user record: $dbError');
    }

    // A farm already on this phone means set-up is done.
    final store = _offline?.store;
    if (store != null && store.rows(LocalTables.farms).isNotEmpty) {
      return ('/', null);
    }

    try {
      final farm = await client
          .from('farms')
          .select()
          .eq('user_id', user.id)
          .maybeSingle()
          .timeout(requestTimeout);
      if (farm != null) return ('/', null);
      return (
        '/create-farm',
        {
          'name': user.userMetadata?['full_name'] ?? '',
          'phone': user.userMetadata?['phone_number'] ?? '',
        },
      );
    } catch (e) {
      debugPrint('Could not check for a farm after signing in: $e');
      return ('/', null);
    }
  }

  /// Turns [e] into a message a farmer can act on. Raw exception text is
  /// never shown.
  void _setErrorFrom(Object e, {bool signingIn = false}) {
    debugPrint('Authentication error: $e');
    final message = e is AuthException ? e.message : e.toString();
    final lower = message.toLowerCase();

    // gotrue wraps a timed-out request in AuthRetryableFetchException.
    if (e is TimeoutException ||
        lower.contains('timeout') ||
        lower.contains('timed out')) {
      _setError('request_timed_out'.tr(), isConnectionError: true);
    } else if (isNetworkError(e)) {
      _setError(
        signingIn
            ? 'sign_in_needs_internet'.tr()
            : 'no_internet_connection'.tr(),
        isConnectionError: true,
      );
    } else if (message.contains('Invalid login credentials')) {
      _setError('invalid_email_or_password'.tr());
    } else if (message.contains('Email not confirmed')) {
      _setError('email_not_confirmed'.tr());
    } else if (message.contains('User already registered')) {
      _setError('user_already_registered'.tr());
    } else if (message.contains('Invalid API key')) {
      _setError('configuration_error'.tr());
    } else {
      _setError(friendlyErrorMessage(e));
    }
  }

  Future<void> internetTest() async {
    _isLoading = true;
    _setError(null);
    notifyListeners();

    try {
      final supabaseService = SupabaseService();
      final isConnected = await supabaseService.testConnection();

      _setError(
        isConnected
            ? 'connection_test_successful'.tr()
            : 'connection_test_failed'.tr(),
        isConnectionError: !isConnected,
      );
    } catch (e) {
      _setError(friendlyErrorMessage(e), isConnectionError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

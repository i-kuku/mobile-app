import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/routing/app_router.dart';
import 'package:ikuku/shared/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
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

  final BuildContext context = navigatorKey.currentState!.context;

  void toggleAuthState() {
    _isSignUp = !_isSignUp;
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
        notifyListeners();
        return;
      }
      final supabaseService = SupabaseService();
      final isConnected = await supabaseService.testConnection();
      if (!isConnected) {
        _setError('unable_to_connect'.tr(), isConnectionError: true);
        _isLoading = false;
        notifyListeners();
        return;
      }

      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final user = res.user;
      debugPrint(
        'Sign up response: ${res.session != null ? 'Session created' : 'No session'}',
      );
      debugPrint('User: ${user?.id ?? 'No user'}');
      if (user != null) {
        try {
          await Supabase.instance.client.from('users').insert({
            'id': user.id,
            'full_name': '',
            'phone_number': '',
          });
          debugPrint('User record created successfully');
        } catch (dbError) {
          debugPrint('Database error creating user record: $dbError');
        } finally {
          if (context.mounted) {
            context.go('/create-farm');
          }
        }
      } else {
        _setError('sign_up_failed'.tr());
      }
    } catch (e) {
      _getRrrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _setError(null);
    _isLoading = true;

    notifyListeners();
    try {
      final supabaseService = SupabaseService();
      final isConnected = await supabaseService.testConnection();
      if (!isConnected) {
        _setError('unable_to_connect'.tr(), isConnectionError: true);
        _isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint('Attempting sign in for email: $email');
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint(
        'Sign in response: ${res.session != null ? 'Session created' : 'No session'}',
      );
      debugPrint('User: ${res.user?.id ?? 'No user'}');

      if (res.user != null) {
        final user = res.user;

        try {
          final userExists = await Supabase.instance.client
              .from('users')
              .select('id')
              .eq('id', user!.id)
              .maybeSingle();
          if (userExists == null) {
            debugPrint('Creating user record for existing auth user');
            await Supabase.instance.client.from('users').insert({
              'id': user.id,
              'full_name': user.userMetadata?['full_name'] ?? '',
              'phone_number': user.userMetadata?['phone_number'] ?? '',
            });
          }
        } catch (dbError) {
          debugPrint('Database error checking/creating user record: $dbError');
        }

        final farm = await Supabase.instance.client
            .from('farms')
            .select()
            .eq('user_id', user!.id)
            .maybeSingle();
        if (farm == null && context.mounted) {
          context.go(
            '/create-farm',
            extra: {
              'name': user.userMetadata?['full_name'] ?? '',
              'phone': user.userMetadata?['phone_number'] ?? '',
            },
          );
        } else {
          if (context.mounted) {
            context.go('/');
          }
        }
      } else {
        _setError('sign_in_failed'.tr());
        notifyListeners();
      }
    } catch (e) {
      _getRrrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _getRrrorMessage(Object e) {
    debugPrint('Authentication error: $e');
    final message = e.toString();
    if (message.contains('SocketException') ||
        message.contains('Failed host lookup') ||
        message.contains('No address associated with hostname') ||
        message.contains('Network is unreachable')) {
      _setError('no_internet_connection'.tr(), isConnectionError: true);
    } else if (message.contains('Invalid login credentials')) {
      _setError('invalid_email_or_password'.tr());
    } else if (message.contains('Email not confirmed')) {
      _setError('email_not_confirmed'.tr());
    } else if (message.contains('User already registered')) {
      _setError('user_already_registered'.tr());
    } else if (message.contains('Invalid API key')) {
      _setError('configuration_error'.tr());
    } else if (e is TimeoutException ||
        message.toLowerCase().contains('timeout') ||
        message.toLowerCase().contains('timed out')) {
      _setError('request_timed_out'.tr(), isConnectionError: true);
    } else {
      _setError('an_error_occurred'.tr(args: [message.split(':').last.trim()]));
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
      _setError('Connection test error: $e', isConnectionError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

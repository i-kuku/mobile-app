import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/routing/app_router.dart';
import 'package:ikuku/shared/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;

  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool _isSignUp = true;

  bool get isSignUp => _isSignUp;

  final BuildContext context = navigatorKey.currentState!.context;

  void toggleAuthState() {
    _isSignUp = !_isSignUp;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      final supabaseService = SupabaseService();
      final isConnected = await supabaseService.testConnection();
      if (!isConnected) {
        _errorMessage = 'unable_to_connect'.tr();
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
        _errorMessage = 'sign_up_failed'.tr();
      }
    } catch (e) {
      _getRrrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      final supabaseService = SupabaseService();
      final isConnected = await supabaseService.testConnection();
      if (!isConnected) {
        _errorMessage = 'unable_to_connect'.tr();
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
        _errorMessage = 'sign_in_failed'.tr();
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
    if (e.toString().contains('SocketException') ||
        e.toString().contains('Failed host lookup') ||
        e.toString().contains('No address associated with hostname') ||
        e.toString().contains('Network is unreachable')) {
      _errorMessage = 'no_internet_connection'.tr();
    } else if (e.toString().contains('Invalid login credentials')) {
      _errorMessage = 'invalid_email_or_password'.tr();
    } else if (e.toString().contains('Email not confirmed')) {
      _errorMessage = 'email_not_confirmed'.tr();
    } else if (e.toString().contains('User already registered')) {
      _errorMessage = 'user_already_registered'.tr();
    } else if (e.toString().contains('Invalid API key')) {
      _errorMessage = 'configuration_error'.tr();
    } else if (e.toString().contains('timeout')) {
      _errorMessage = 'request_timed_out'.tr();
    } else {
      _errorMessage = 'an_error_occurred'.tr(
        args: [e.toString().split(':').last.trim()],
      );
    }
  }

  Future<void> internetTest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final supabaseService = SupabaseService();
      final isConnected = await supabaseService.testConnection();

      _errorMessage = isConnected
          ? 'connection_test_successful'.tr()
          : 'connection_test_failed'.tr();
    } catch (e) {
      _errorMessage = 'Connection test error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

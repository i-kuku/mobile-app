import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:ikuku/routing/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _selectedLanguage = "en";
  bool _isLoading = false;

  String get selectedLanguage => _selectedLanguage;

  bool get isLoading => _isLoading;

  LanguageProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadLanguage();
  }

  /// Applies [locale] via the app navigator's context, if it is mounted.
  /// Looked up on use rather than stored, so creating the provider before
  /// the navigator exists is safe.
  void _applyLocale(Locale locale) {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.setLocale(locale);
    }
  }

  Future<void> loadLanguage() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('app_language');

    if (savedLanguage == null) {
      await prefs.setString('app_language', 'en');
      _applyLocale(const Locale('en'));
      _selectedLanguage = 'en';
    } else {
      _selectedLanguage = savedLanguage;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);

    _selectedLanguage = lang;
    _applyLocale(Locale(lang));
    _isLoading = false;
    notifyListeners();
  }
}

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

  final BuildContext context = navigatorKey.currentState!.context;
  Future<void> loadLanguage() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('app_language');

    if (savedLanguage == null) {
      await prefs.setString('app_language', 'en');
      if (context.mounted) {
        context.setLocale(const Locale('en'));
      }
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
    if (context.mounted) {
      context.setLocale(Locale(lang));
    }
    _isLoading = false;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../app_theme.dart';

class LanguageSelectionPage extends StatefulWidget {
  final VoidCallback? onContinue;
  const LanguageSelectionPage({super.key, this.onContinue});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('app_language');

    if (savedLanguage == null) {
      // Set English as default on first time
      await prefs.setString('app_language', 'en');
      if (mounted) {
        context.setLocale(const Locale('en'));
      }
      setState(() {
        _selectedLanguage = 'en';
      });
    } else {
      setState(() {
        _selectedLanguage = savedLanguage;
      });
    }
  }

  Future<void> _setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    setState(() {
      _selectedLanguage = lang;
    });
    // Change app locale immediately
    if (mounted) {
      context.setLocale(Locale(lang));
    }
  }

  void _onContinue() {
    if (widget.onContinue != null) widget.onContinue!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Image.asset('assets/icons/app-logo.png', height: 56),
            const SizedBox(height: 16),
            Text(
              'welcome'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'choose_language'.tr(),
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 32),
            _languageOption('english'.tr(), 'en'),
            const SizedBox(height: 16),
            _languageOption('swahili'.tr(), 'sw'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedLanguage != null ? _onContinue : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  foregroundColor: CustomColors.text,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: CustomColors.buttonGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Text(
                      'continue'.tr().toUpperCase(),
                      style: const TextStyle(
                        color: CustomColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'language_change_hint'.tr(),
              style: const TextStyle(color: Colors.black45, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(String label, String value) {
    final selected = _selectedLanguage == value;
    return GestureDetector(
      onTap: () => _setLanguage(value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? CustomColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: selected ? CustomColors.primary : Colors.black,
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? CustomColors.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

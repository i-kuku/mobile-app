import 'package:flutter/material.dart';
import 'package:ikuku/features/settings/languages/presentation/components/language_select_option.dart';
import 'package:ikuku/features/settings/languages/provider/language_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelectionPage extends StatelessWidget {
  final VoidCallback? onContinue;
  const LanguageSelectionPage({super.key, this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Consumer<LanguageProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Image.asset('assets/icons/app-logo.png', height: 56),
                const SizedBox(height: 16),
                Text(
                  'welcome'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'choose_language'.tr(),
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 32),
                LanguageSelectOption(),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : onContinue,
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
          );
        },
      ),
    );
  }
}

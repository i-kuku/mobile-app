import 'package:flutter/material.dart';
import 'package:ikuku/features/settings/languages/provider/language_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class LanguageOptionWidget extends StatelessWidget {
  final String value;
  final String label;
  const LanguageOptionWidget({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, provider, child) {
        final bool selected = provider.selectedLanguage == value;
        return GestureDetector(
          onTap: () => provider.setLanguage(value),
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
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? CustomColors.primary : Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

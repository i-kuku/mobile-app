import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

class FeatureButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const FeatureButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap, required TextStyle style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: CustomColors.buttonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton.icon(
          icon: icon != null ? Icon(icon, color: CustomColors.text) : null,
          label: Text(
            label.toUpperCase(),
            style: TextStyle(color: CustomColors.text),
          ),
          onPressed: onTap,
          style:
              ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: CustomColors.text,
                textStyle: const TextStyle(fontWeight: FontWeight.w600,letterSpacing: 1.2),
              ).copyWith(
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
              ),
        ),
      ),
    );
  }
}

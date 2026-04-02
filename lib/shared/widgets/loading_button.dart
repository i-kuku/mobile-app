import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

enum LoadingButtonType { elevated, outlined, text }

class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final LoadingButtonType type;
  final bool autofocus;
  final bool isGradient;
  final bool isLoading;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.type = LoadingButtonType.elevated,
    this.autofocus = false,
    this.isGradient = true,
    this.isLoading = false

  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle =
        style ??
        ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        );
    final buttonChild = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          )
        : child;

    switch (type) {
      case LoadingButtonType.outlined:
        return showGradient(
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : onPressed,
            style: buttonStyle,
            autofocus: autofocus,
            child: buttonChild,
          ),
        );
      case LoadingButtonType.text:
        return showGradient(
          child: TextButton(
            onPressed: isLoading
                ? null
                : onPressed,
            style: buttonStyle,
            autofocus: autofocus,
            child: buttonChild,
          ),
        );
      default:
        return showGradient(
          child: ElevatedButton(
            onPressed:isLoading
                ? null
                : onPressed,
            style: buttonStyle,
            autofocus: autofocus,
            child: buttonChild,
          ),
        );
    }
  }

  Widget showGradient({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: CustomColors.buttonGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

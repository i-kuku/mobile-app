import 'package:flutter/material.dart';
import 'package:ikuku/app_theme.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isSuccess;
  final VoidCallback onOkPressed;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.isSuccess,
    required this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CustomColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        title,
        style: appTheme.textTheme.titleLarge?.copyWith(
          color: isSuccess ? CustomColors.primary : Colors.red,
        ),
      ),
      content: Text(message, style: appTheme.textTheme.bodyLarge),
      actions: [
        TextButton(
          onPressed: onOkPressed,
          child: Text(
            'OK',
            style: appTheme.textTheme.titleMedium?.copyWith(
              color: isSuccess ? CustomColors.primary : Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}

void showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  required bool isSuccess,
  required VoidCallback onOkPressed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: title,
        message: message,
        isSuccess: isSuccess,
        onOkPressed: () {
          Navigator.of(context).pop(); // Close the dialog
          onOkPressed(); // Execute the provided callback
        },
      );
    },
  );
}

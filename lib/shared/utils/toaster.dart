
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/routing/app_router.dart';
import 'package:ikuku/theme/app_theme.dart';


void showToast(String message, {bool isError = false}) {
  final BuildContext context = navigatorKey.currentState!.context;

  final errorColor = CustomColors.errorColor;
  final primaryColor = Theme.of(context).colorScheme.primary;
  DelightToastBar.removeAll();
  DelightToastBar(
    position: DelightSnackbarPosition.top,
    autoDismiss: true,
    snackbarDuration: Duration(seconds: 3),
    builder: (context) => ToastCard(
      leading: Icon(
        isError ? Icons.error_outline : Icons.check_circle,
        size: 28,
        color: isError ? errorColor : primaryColor,
      ),
      title: Text(
        message,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
  ).show(context);
}

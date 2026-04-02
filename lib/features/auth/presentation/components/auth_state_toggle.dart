import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthStateToggle extends StatelessWidget {
  const AuthStateToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.isSignUp
                  ? 'have_an_account'.tr()
                  : "dont_have_account".tr(),
            ),
            GestureDetector(
              onTap: provider.isLoading ? null : provider.toggleAuthState,
              child: Text(
                provider.isSignUp ? 'sign_in'.tr() : 'sign_up'.tr(),
                style: TextStyle(
                  color: Colors.green[800],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

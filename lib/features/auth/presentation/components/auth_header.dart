import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return Wrap(
          runSpacing: 8.0,
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Image.asset('assets/icons/app-logo.png', height: 56),
                  SizedBox(height: 8),
                  Text(
                    'i-kuku',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Text(
              provider.isSignUp ? "create_account".tr() : "sign_in".tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              provider.isSignUp
                  ? 'enter_email_password_create'.tr()
                  : 'enter_email_password_signin'.tr(),
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        );
      },
    );
  }
}

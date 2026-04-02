import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/auth/presentation/components/auth_error_widget.dart';
import 'package:ikuku/features/auth/presentation/components/auth_state_toggle.dart';
import 'package:ikuku/features/auth/presentation/components/sign_in_widget.dart';
import 'package:ikuku/features/auth/presentation/components/sign_up_widget.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:ikuku/shared/widgets/loading_button.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 32,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          Image.asset('assets/icons/app-logo.png', height: 56),
                          SizedBox(height: 8),
                          Text(
                            'i-kuku',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    provider.isSignUp ? SignUpWidget() : SignInWidget(),
                    AuthErrorWidget(
                      errorMessage: provider.errorMessage,
                      internetTest: provider.internetTest,
                    ),

                    LoadingButton(
                      isGradient: true,
                      isLoading: provider.isLoading,
                      onPressed: () {},
                      child: Text(
                        provider.isSignUp ? 'sign_up'.tr() : 'sign_in'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    AuthStateToggle(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/auth/presentation/components/auth_error_widget.dart';
import 'package:ikuku/features/auth/presentation/components/auth_header.dart';
import 'package:ikuku/features/auth/presentation/components/auth_state_toggle.dart';
import 'package:ikuku/features/auth/presentation/components/sign_in_widget.dart';
import 'package:ikuku/features/auth/presentation/components/sign_up_widget.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:ikuku/shared/widgets/loading_button.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  void onPressed(bool isLogin) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      if (isLogin) {
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).login(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        await Provider.of<AuthProvider>(context, listen: false).register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _repeatPasswordController.text.trim(),
        );
      }
    } else {
      debugPrint("Validation failed");
    }
  }

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      AuthHeader(),
                      provider.isSignUp
                          ? SignUpWidget(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              repeatPasswordController:
                                  _repeatPasswordController,
                            )
                          : SignInWidget(
                              emailController: _emailController,
                              passwordController: _passwordController,
                            ),
                      AuthErrorWidget(
                        errorMessage: provider.errorMessage,
                        internetTest: provider.internetTest,
                      ),

                      LoadingButton(
                        isGradient: true,
                        isLoading: provider.isLoading,
                        onPressed: () => onPressed(!provider.isSignUp),
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
            ),
          );
        },
      ),
    );
  }
}

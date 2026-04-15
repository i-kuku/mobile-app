import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:ikuku/shared/widgets/text_field_widget.dart';
import 'package:provider/provider.dart';

class SignUpWidget extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController repeatPasswordController;
  SignUpWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.repeatPasswordController,
  });

  final FocusNode _emailFocus = FocusNode();

  final FocusNode _passwordFocus = FocusNode();

  final FocusNode _repeatPasswordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return Wrap(
          runSpacing: 20.0,

          children: [
            TextFieldWidget(
              labelText: "Email",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'type_your_email'.tr(),
              isEmail: true,
              focusNode: _emailFocus,
              nextFocusNode: _passwordFocus,
              isLoading: provider.isLoading,
            ),

            TextFieldWidget(
              labelText: "Password",
              controller: passwordController,
              isPassword: true,
              hintText: 'type_your_password'.tr(),
              focusNode: _passwordFocus,
              isLoading: provider.isLoading,
              nextFocusNode: _repeatPasswordFocus,
            ),

            TextFieldWidget(
              labelText: 'repeat_password'.tr(),
              controller: repeatPasswordController,
              isPassword: true,
              hintText: 'repeat_your_password'.tr(),
              focusNode: _repeatPasswordFocus,
              isLoading: provider.isLoading,
            ),
          ],
        );
      },
    );
  }
}

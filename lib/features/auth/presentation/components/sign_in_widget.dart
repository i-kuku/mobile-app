import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:ikuku/shared/widgets/text_field_widget.dart';
import 'package:provider/provider.dart';

class SignInWidget extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  const SignInWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  // Owned by State so focus survives rebuilds and the nodes are disposed.
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return Wrap(
          runSpacing: 20.0,
          children: [
            TextFieldWidget(
              labelText: "Email",
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'type_your_email'.tr(),
              isEmail: true,
              focusNode: _emailFocus,
              nextFocusNode: _passwordFocus,
              isLoading: false,
            ),

            TextFieldWidget(
              labelText: "Password",
              controller: widget.passwordController,
              isPassword: true,
              hintText: 'type_your_password'.tr(),
              focusNode: _passwordFocus,
              isLoading: false,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'forgot_password'.tr(),
                  style: TextStyle(color: Colors.green[800]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

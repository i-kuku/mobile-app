import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:ikuku/shared/widgets/text_field_widget.dart';
import 'package:provider/provider.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return Wrap(
          children: [
            Text(
              "sign_in".tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'enter_email_password_signin'.tr(),
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 32),

            TextFieldWidget(
              labelText: "Email",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'type_your_email'.tr(),
              isEmail: true,
              focusNode: _emailFocus,
              nextFocusNode: _passwordFocus,
              isLoading: false,
            ),
            SizedBox(height: 20),

            TextFieldWidget(
              labelText: "Password",
              controller: _passwordController,
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

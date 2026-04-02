import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:ikuku/shared/widgets/text_field_widget.dart';
import 'package:provider/provider.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _repeatPasswordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Text(
              "create_account".tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'enter_email_password_create'.tr(),
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
              isLoading: provider.isLoading,
            ),
            SizedBox(height: 20),
         
            TextFieldWidget(
              labelText: "Password",
              controller: _passwordController,
              isPassword: true,
              hintText: 'type_your_password'.tr(),
              focusNode: _passwordFocus,
              isLoading: provider.isLoading,
              nextFocusNode: _repeatPasswordFocus,
            ),
            SizedBox(height: 20),

            TextFieldWidget(
              labelText: 'repeat_password'.tr() ,
              controller: _repeatPasswordController,
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

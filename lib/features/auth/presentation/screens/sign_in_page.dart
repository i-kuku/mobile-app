import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/shared/services/supabase_service.dart';
import 'package:ikuku/shared/widgets/loading_button.dart';
import 'package:ikuku/shared/widgets/text_field_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _repeatPasswordFocus = FocusNode();
  bool _isLoading = false;
  String? _error;
  bool _isSignUp = false;



  @override
  void initState() {
    super.initState();
    _isSignUp = true;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 32),
                Text(
                  _isSignUp ? "create_account".tr() : "sign_in".tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _isSignUp
                      ? 'enter_email_password_create'.tr()
                      : 'enter_email_password_signin'.tr(),
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 32),
                Text('Email', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextFieldWidget(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'type_your_email'.tr(),
                  isEmail: true,
                  focusNode: _emailFocus,
                  nextFocusNode: _passwordFocus,
                  isLoading: false,
                ),
                SizedBox(height: 20),
                Text('Password', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextFieldWidget(
                  controller: _passwordController,
                  isPassword: true,
                 hintText: 'type_your_password'.tr(),
                 focusNode: _passwordFocus,
                 isLoading: false,
                 nextFocusNode: _repeatPasswordFocus,
                ),
                if (!_isSignUp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      child: Text(
                        'forgot_password'.tr(),
                        style: TextStyle(color: Colors.green[800]),
                      ),
                    ),
                  ),
                if (_isSignUp) ...[
                  SizedBox(height: 20),
                  Text(
                    'repeat_password'.tr(),
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _repeatPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration('repeat_your_password'.tr()),
                  ),
                ],
                if (_error != null) ...[
                  SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 8),
                  // Debug button to test connection
                  if (_error!.contains('internet') ||
                      _error!.contains('connection'))
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        try {
                          final supabaseService = SupabaseService();
                          final isConnected = await supabaseService
                              .testConnection();
                          setState(() {
                            _error = isConnected
                                ? 'connection_test_successful'.tr()
                                : 'connection_test_failed'.tr();
                            _isLoading = false;
                          });
                        } catch (e) {
                          setState(() {
                            _error = 'Connection test error: $e';
                            _isLoading = false;
                          });
                        }
                      },
                      child: Text('Test Connection'),
                    ),
                ],
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFC727), Color(0xFF8DC63F)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(minHeight: 48),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isSignUp ? 'sign_up'.tr() : 'sign_in'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp
                            ? 'have_an_account'.tr()
                            : "dont_have_account".tr(),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                            _error = null;
                          });
                        },
                        child: Text(
                          _isSignUp ? 'sign_in'.tr() : 'sign_up'.tr(),
                          style: TextStyle(
                            color: Colors.green[800],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

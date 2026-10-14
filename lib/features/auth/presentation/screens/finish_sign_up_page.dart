import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/auth/data/pending_registration.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:ikuku/shared/widgets/loading_button.dart';
import 'package:ikuku/shared/widgets/text_field_widget.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// The last step of a sign-up started offline: creates the account as soon
/// as there's a connection, trying again by itself until then.
class FinishSignUpPage extends StatefulWidget {
  const FinishSignUpPage({super.key, this.retryInterval});

  /// How often to try again while offline. The phone can regain internet
  /// without its network changing, so connectivity events alone miss it.
  final Duration? retryInterval;

  @override
  State<FinishSignUpPage> createState() => _FinishSignUpPageState();
}

class _FinishSignUpPageState extends State<FinishSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  ConnectivityService? _connectivity;
  Timer? _retryTimer;
  String? _email;

  @override
  void initState() {
    super.initState();
    _connectivity = OfflineServices.instance.connectivity
      ..addListener(_onConnectivityChanged);
    _retryTimer = Timer.periodic(
      widget.retryInterval ?? const Duration(seconds: 20),
      (_) => _retryIfWaiting(),
    );
    PendingRegistrationStore.load().then((pending) {
      if (mounted) setState(() => _email = pending?.email);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _submit());
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _connectivity?.removeListener(_onConnectivityChanged);
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (_connectivity?.isOnline ?? false) _retryIfWaiting();
  }

  void _retryIfWaiting() {
    if (!mounted) return;
    final status = context.read<AuthProvider>().pendingSignUpStatus;
    if (status == PendingSignUpStatus.waitingForNetwork) _submit();
  }

  Future<void> _submit({String? password}) {
    if (!mounted) return Future.value();
    return context.read<AuthProvider>().completePendingRegistration(
      password: password,
    );
  }

  void _submitPassword() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _submit(password: _passwordController.text.trim());
    }
  }

  void _goToSignIn() {
    context.read<AuthProvider>().showSignIn();
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final status = auth.pendingSignUpStatus;
    final busy =
        status == PendingSignUpStatus.idle ||
        status == PendingSignUpStatus.working;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'finish_signup_title'.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                ..._body(status, auth),
                const SizedBox(height: 32),
                if (busy)
                  const Center(child: CircularProgressIndicator())
                else
                  LoadingButton(
                    onPressed: switch (status) {
                      PendingSignUpStatus.needsPassword => _submitPassword,
                      PendingSignUpStatus.confirmEmail ||
                      PendingSignUpStatus.accountExists => _goToSignIn,
                      _ => () => _submit(),
                    },
                    child: Text(
                      switch (status) {
                        PendingSignUpStatus.needsPassword =>
                          'create_account_now'.tr(),
                        PendingSignUpStatus.confirmEmail ||
                        PendingSignUpStatus.accountExists =>
                          'go_to_sign_in'.tr(),
                        _ => 'try_again'.tr(),
                      },
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (!busy)
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/auth'),
                      child: Text(
                        'change_sign_up_details'.tr(),
                        style: TextStyle(color: Colors.green[800]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(PendingSignUpStatus status, AuthProvider auth) {
    Widget message(IconData icon, String text, {Color? color}) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color ?? CustomColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: color ?? Colors.black87),
          ),
        ),
      ],
    );

    switch (status) {
      case PendingSignUpStatus.idle:
      case PendingSignUpStatus.working:
        return [
          message(Icons.cloud_upload_outlined, 'finish_signup_working'.tr()),
        ];
      case PendingSignUpStatus.waitingForNetwork:
        return [
          message(Icons.cloud_off_outlined, 'finish_signup_waiting'.tr()),
        ];
      case PendingSignUpStatus.needsPassword:
        return [
          message(Icons.lock_outline, 'finish_signup_reenter_password'.tr()),
          const SizedBox(height: 20),
          TextFieldWidget(
            labelText: 'Password',
            controller: _passwordController,
            isPassword: true,
            hintText: 'type_your_password'.tr(),
            focusNode: _passwordFocus,
            isLoading: false,
          ),
        ];
      case PendingSignUpStatus.confirmEmail:
        return [
          message(
            Icons.mark_email_read_outlined,
            'finish_signup_confirm_email'.tr(args: [_email ?? '']),
          ),
        ];
      case PendingSignUpStatus.accountExists:
        return [
          message(Icons.person_outline, 'finish_signup_account_exists'.tr()),
        ];
      case PendingSignUpStatus.failed:
        return [
          message(
            Icons.error_outline,
            auth.errorMessage ?? 'something_went_wrong_message'.tr(),
            color: CustomColors.errorColor,
          ),
        ];
    }
  }
}

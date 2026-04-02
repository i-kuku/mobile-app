import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/routing/app_router.dart';
import 'package:ikuku/shared/widgets/loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void handleForgotPassword() async {
  final phoneController = TextEditingController();
  final answerController = TextEditingController();
  String? recoveryQuestion;
  String? userId;
  bool isVerifyingAnswer = false;

  showDialog(
    context: navigatorKey.currentState!.context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text('reset_password'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isVerifyingAnswer) ...[
                Text('enter_phone_to_recover'.tr()),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('phone_hint'.tr()),
                ),
              ] else ...[
                Text(
                  '${'security_question'.tr()}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(recoveryQuestion?.tr() ?? ''),
                const SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  decoration: _inputDecoration('answer_placeholder'.tr()),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            LoadingButton(
              onPressed: () async {
                if (!isVerifyingAnswer) {
                  // Step 1: Fetch Question
                  final phone = phoneController.text.trim();
                  if (phone.isEmpty) return;

                  try {
                    final data = await Supabase.instance.client
                        .from('users')
                        .select('id, recovery_question')
                        .eq('phone_number', phone)
                        .maybeSingle();

                    if (data == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('user_not_found'.tr())),
                        );
                      }
                      return;
                    }

                    recoveryQuestion = data['recovery_question'];
                    userId = data['id'];
                    setDialogState(() {
                      isVerifyingAnswer = true;
                    });
                  } catch (e) {
                    print('Error fetching question: $e');
                  }
                } else {
                  // Step 2: Verify Answer
                  final answer = answerController.text.trim().toLowerCase();
                  try {
                    final data = await Supabase.instance.client
                        .from('users')
                        .select('id')
                        .eq('id', userId!)
                        .eq('recovery_answer', answer)
                        .maybeSingle();

                    if (data == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('incorrect_answer'.tr())),
                        );
                      }
                      return;
                    }

                    // Success! Redirect to Reset Password
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.go('/reset-password');
                    }
                  } catch (e) {
                    print('Error verifying answer: $e');
                  }
                }
              },
              type: LoadingButtonType.elevated,
              child: Text(
                !isVerifyingAnswer
                    ? 'fetch_question'.tr()
                    : 'verify_answer'.tr(),
              ),
            ),
          ],
        );
      },
    ),
  );
}

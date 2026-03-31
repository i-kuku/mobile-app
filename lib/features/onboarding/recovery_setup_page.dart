import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app_theme.dart';
import '../../../shared/widgets/loading_button.dart';

class RecoverySetupPage extends StatefulWidget {
  const RecoverySetupPage({super.key});

  @override
  State<RecoverySetupPage> createState() => _RecoverySetupPageState();
}

class _RecoverySetupPageState extends State<RecoverySetupPage> {
  String? _selectedQuestion;
  final _answerController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final List<String> _questions = [
    'question_1',
    'question_2',
    'question_3',
    'question_4',
  ];

  bool get _isEditing =>
      (GoRouterState.of(context).extra as Map?)?.containsKey('initialStep') ??
      false;

  Future<void> _onSave() async {
    if (_selectedQuestion == null || _answerController.text.trim().isEmpty) {
      setState(() {
        _error = 'please_fill_all_fields'.tr();
      });
      return;
    }

    setState(() {
      _error = null;
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      context.go('/sign-in');
      return;
    }

    try {
      await Supabase.instance.client
          .from('users')
          .update({
            'recovery_question': _selectedQuestion,
            'recovery_answer': _answerController.text.trim().toLowerCase(),
          })
          .eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('recovery_saved'.tr())));
        if (_isEditing) {
          context.pop();
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      // Loading handled by LoadingButton
    }
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
                const SizedBox(height: 16),
                Text(
                  'setup_recovery'.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'setup_recovery_desc'.tr(),
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Text(
                  'security_question'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedQuestion,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _questions.map((q) {
                    return DropdownMenuItem(value: q, child: Text(q.tr()));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedQuestion = val;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'secret_answer'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    hintText: 'answer_placeholder'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: CustomColors.buttonGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: LoadingButton(
                      onPressed: _onSave,
                      type: LoadingButtonType.elevated,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'continue'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
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
}

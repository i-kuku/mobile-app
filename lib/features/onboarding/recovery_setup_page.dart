import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/auth/data/pending_registration.dart';
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:ikuku/theme/app_theme.dart';
import '../../../shared/widgets/loading_button.dart';

class RecoverySetupPage extends StatefulWidget {
  const RecoverySetupPage({super.key});

  @override
  State<RecoverySetupPage> createState() => _RecoverySetupPageState();
}

class _RecoverySetupPageState extends State<RecoverySetupPage> {
  String? _selectedQuestion;
  final _answerController = TextEditingController();
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

    final question = _selectedQuestion!;
    final answer = _answerController.text.trim().toLowerCase();

    try {
      final sync = OfflineServices.instance.sync;
      final userId = sync.currentUserId;
      if (userId == null) {
        final pending = await PendingRegistrationStore.load();
        if (pending == null) {
          if (mounted) context.go('/auth');
          return;
        }
        // The account is created later; keep these for then.
        await PendingRegistrationStore.save(
          pending.copyWith(recoveryQuestion: question, recoveryAnswer: answer),
        );
        if (mounted) context.go('/finish-signup');
        return;
      }

      // Queued for the server without keeping the answer on the phone.
      await sync.queueUpdate(
        LocalTables.users,
        recordId: userId,
        values: {'recovery_question': question, 'recovery_answer': answer},
        match: {'id': userId},
      );

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
      debugPrint('Could not save the recovery question: $e');
      setState(() {
        _error = friendlyErrorMessage(e);
      });
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
                  initialValue: _selectedQuestion,
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

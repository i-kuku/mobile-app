import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/theme/app_theme.dart';

class RecoveryPhonePage extends StatefulWidget {
  const RecoveryPhonePage({super.key});

  @override
  State<RecoveryPhonePage> createState() => _RecoveryPhonePageState();
}

class _RecoveryPhonePageState extends State<RecoveryPhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _recoveryNumber1 = '---';
  String? _recoveryNumber2;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleInstantSave() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      final newNumber = _phoneController.text.trim();

      if (_recoveryNumber1 == '---' || _recoveryNumber1.isEmpty) {
        _recoveryNumber1 = newNumber;
      } else {
        _recoveryNumber2 = newNumber;
      }
      _phoneController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recovery phone number added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "profile".tr(),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: CustomColors.primary,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text(
                "recovery_phone_numbers".tr(),
                style: const TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recovery number 1',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _recoveryNumber1,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recovery number 2',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _recoveryNumber2 ?? '----',
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                "add_recovery_number".tr(),
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(fontSize: 20),
              ),
              SizedBox(height: 16),
              Text(
                "phone_number".tr(),
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontSize: 20,
                  color: CustomColors.primary,
                ),
              ),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "0712 000 000",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: CustomColors.secondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Text(
                      "cancel".tr(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(color: CustomColors.text),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: _handleInstantSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "save".tr(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

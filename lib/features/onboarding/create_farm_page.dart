import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateFarmPage extends StatefulWidget {
  final String name;
  final String phone;
  const CreateFarmPage({super.key, this.name = '', this.phone = ''});

  @override
  State<CreateFarmPage> createState() => _CreateFarmPageState();
}

class _CreateFarmPageState extends State<CreateFarmPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final _farmNameController = TextEditingController();
  final _farmLocationController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
  }

  void _onContinue() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    if (!_acceptedTerms) {
      setState(() {
        _error = 'You must accept the Terms and Conditions to continue.';
        _isLoading = false;
      });
      return;
    }
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _farmNameController.text.trim().isEmpty ||
        _farmLocationController.text.trim().isEmpty) {
      setState(() {
        _error = 'please_fill_all_fields'.tr();
        _isLoading = false;
      });
      return;
    }

    if (_phoneController.text.trim().length < 10) {
      setState(() {
        _error = 'enter_valid_phone_number'.tr();
        _isLoading = false;
      });
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _error = 'must_be_signed_in'.tr();
        _isLoading = false;
      });
      return;
    }
    try {
      // First, update the user record with the provided information
      await Supabase.instance.client.from('users').upsert({
        'id': user.id,
        'full_name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
      });

      // Then create the farm record
      await Supabase.instance.client.from('farms').insert({
        'user_id': user.id,
        'farm_name': _farmNameController.text.trim(),
        'farm_location': _farmLocationController.text.trim(),
      });

      context.go('/recovery-setup');
    } catch (e) {
      setState(() {
        _error = 'failed_to_create_farm'.tr(args: [e.toString()]);
      });
    }
    setState(() {
      _isLoading = false;
    });
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
                SizedBox(height: 16),
                Text(
                  'create_your_farm'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'enter_farm_details'.tr(),
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 32),
                Text(
                  'enter_full_name'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'type_here'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'phone_number'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: 'phone_hint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'farm_name'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _farmNameController,
                  decoration: InputDecoration(
                    hintText: 'farm_name_hint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'farm_location'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _farmLocationController,
                  decoration: InputDecoration(
                    hintText: 'farm_location_hint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Colors.red)),
                ],
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (val) {
                        setState(() {
                          _acceptedTerms = val ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptedTerms = !_acceptedTerms;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            'By using this app, you accept the Terms and Conditions.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onContinue,
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
                                'continue'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
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

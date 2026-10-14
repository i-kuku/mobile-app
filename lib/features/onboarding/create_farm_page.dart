import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/auth/data/pending_registration.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

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

  /// Set when the account is still to be created, i.e. sign-up started
  /// without a connection.
  PendingRegistration? _pending;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
    _loadPendingRegistration();
  }

  Future<void> _loadPendingRegistration() async {
    if (OfflineServices.instance.sync.currentUserId != null) return;
    final pending = await PendingRegistrationStore.load();
    if (pending == null || !mounted) return;
    setState(() {
      _pending = pending;
      // Coming back to this step after a restart.
      if (_nameController.text.isEmpty) {
        _nameController.text = pending.fullName ?? '';
      }
      if (_phoneController.text.isEmpty) {
        _phoneController.text = pending.phone ?? '';
      }
      _farmNameController.text = pending.farmName ?? '';
      _farmLocationController.text = pending.farmLocation ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _farmNameController.dispose();
    _farmLocationController.dispose();
    super.dispose();
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
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final farmName = _farmNameController.text.trim();
    final farmLocation = _farmLocationController.text.trim();

    try {
      final sync = OfflineServices.instance.sync;
      final userId = sync.currentUserId;
      if (userId != null) {
        // Saved on the phone at once; it reaches the server when it can.
        await sync.mergeRow(LocalTables.users, {
          'id': userId,
          'full_name': name,
          'phone_number': phone,
        });
        final farm = {
          'user_id': userId,
          'farm_name': farmName,
          'farm_location': farmLocation,
        };
        final existing = sync.store.rows(LocalTables.farms).firstOrNull;
        if (existing == null) {
          await sync.insertRow(LocalTables.farms, farm);
        } else {
          // Coming back to this step must not create a second farm.
          await sync.updateRow(
            LocalTables.farms,
            localId: LocalStore.idOf(existing),
            values: farm,
            match: {'user_id': userId},
          );
        }
      } else {
        final pending = await PendingRegistrationStore.load();
        if (pending == null) {
          setState(() {
            _error = 'must_be_signed_in'.tr();
            _isLoading = false;
          });
          return;
        }
        // The account is created later; keep these for then.
        await PendingRegistrationStore.save(
          pending.copyWith(
            fullName: name,
            phone: phone,
            farmName: farmName,
            farmLocation: farmLocation,
          ),
        );
      }
      if (mounted) context.go('/recovery-setup');
    } catch (e) {
      debugPrint('Could not save the farm: $e');
      if (mounted) setState(() => _error = friendlyErrorMessage(e));
    }
    if (mounted) setState(() => _isLoading = false);
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
                if (_pending != null) ...[
                  SizedBox(height: 16),
                  _OfflineSignUpNote(),
                ],
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

/// Explains that the account is created once the phone is back online.
class _OfflineSignUpNote extends StatelessWidget {
  const _OfflineSignUpNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF8E2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('sign_up_saved_offline'.tr())),
        ],
      ),
    );
  }
}

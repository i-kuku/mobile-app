import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:ikuku/shared/widgets/loading_button.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';


class EditProfilePage extends StatefulWidget {
  final String? initialName;
  final String? initialLocation;
  final String? initialPhone;
  final String? initialAvatarUrl;

  const EditProfilePage({
    super.key,
    this.initialName,
    this.initialLocation,
    this.initialPhone,
    this.initialAvatarUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  // bool _loading = false;
  final ImagePicker _picker = ImagePicker();
  File? _localImageFile;
  String? _uploadedAvatarUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _locationController = TextEditingController(
      text: widget.initialLocation ?? '',
    );
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _uploadedAvatarUrl = widget.initialAvatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 400,
      );

      if (pickedFile == null) return;

      setState(() {
        _localImageFile = File(pickedFile.path);
        _isUploadingImage = true;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final fileExtension = pickedFile.path.split('.').last;
      final filePath = '${user.id}/profile_avatar.$fileExtension';

      await Supabase.instance.client.storage.from('avatars').upload(
            filePath,
            _localImageFile!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String publicUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(filePath);

      setState(() {
        _uploadedAvatarUrl = publicUrl;
        _isUploadingImage = false;
      });
    } catch (e) {
      debugPrint('Storage Upload Failed: $e');
      if (!mounted) return;
      // Photos go straight to the server, so an unsent one isn't kept.
      setState(() {
        _isUploadingImage = false;
        _localImageFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNetworkError(e)
                ? 'photo_needs_internet'.tr()
                : friendlyErrorMessage(e),
          ),
        ),
      );
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: CustomColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                context.pop();
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: CustomColors.primary),
              title: const Text('Take a Photo'),
              onTap: () {
                context.pop();
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final sync = OfflineServices.instance.sync;
      final userId = sync.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Saved on the phone at once; it reaches the server when it can.
      await sync.mergeRow(LocalTables.users, {
        'id': userId,
        'full_name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        if (_uploadedAvatarUrl != null) 'avatar_url': _uploadedAvatarUrl,
      });
      final farm = sync.store.rows(LocalTables.farms).firstOrNull;
      if (farm != null) {
        await sync.updateRow(
          LocalTables.farms,
          localId: LocalStore.idOf(farm),
          values: {'farm_location': _locationController.text.trim()},
          match: {'user_id': userId},
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sync.isOnline
                  ? 'profile_updated_successfully'.tr()
                  : 'saved_will_upload'.tr(),
            ),
          ),
        );
        Navigator.pop(context, {
          'name': _nameController.text.trim(),
          'location': _locationController.text.trim(),
          'phone': _phoneController.text.trim(),
          'avatar_url':_uploadedAvatarUrl,
        });
      }
    } catch (e) {
      debugPrint('Profile save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tr('failed_to_update_profile'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  ImageProvider? avatarImage;
    if (_localImageFile != null) {
      avatarImage = FileImage(_localImageFile!);
    } else if (_uploadedAvatarUrl != null && _uploadedAvatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(_uploadedAvatarUrl!);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('edit_profile'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[400],
                      backgroundImage: avatarImage,
                      // Offline the saved photo can't load; leave the plain circle.
                      onBackgroundImageError: avatarImage == null
                          ? null
                          : (_, _) {},
                      child: avatarImage == null
                          ? Text(
                              _nameController.text.trim().isNotEmpty
                                  ? _nameController.text.trim()[0].toUpperCase()
                                  : 'O',

                    style: const TextStyle(fontSize: 48, color: Colors.black38),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _isUploadingImage ? null : _showImageSourceOptions,
            icon: const Icon(Icons.edit, size: 16, color: Colors.green),
            label: const Text(
              'Edit profile picture',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
              Text(
                'full_name_label'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'enter_full_name'.tr(),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: CustomColors.primary,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'please_enter_name'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'farm_location_label'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'enter_farm_location'.tr(),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: CustomColors.primary,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'please_enter_location'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Text(
                'phone_number_label'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'enter_phone_number'.tr(),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CustomColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: CustomColors.primary,
                    ),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'please_enter_phone'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

            
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: CustomColors.buttonGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: LoadingButton(
                    onPressed: _saveProfile,
                    type: LoadingButtonType.elevated,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'save_changes'.tr(),
                      style: const TextStyle(
                        color: CustomColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
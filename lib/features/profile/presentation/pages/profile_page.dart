import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/profile/presentation/pages/edit_profile_page.dart';
// import 'package:ikuku/features/profile/presentation/pages/recovery_phone_page.dart';
import 'package:ikuku/features/profile/presentation/widgets/menu_card.dart';
import 'package:ikuku/features/profile/presentation/widgets/pop_up.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? location;
  String? phone;
  String? farmName;
  String? farmLocation;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => loading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }
    try {
      final userResponse = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      final farmResponse = await Supabase.instance.client
          .from('farms')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      setState(() {
        name =
            userResponse?['full_name'] ??
            user.email?.split('@').first ??
            'Farmer';
        phone = userResponse?['phone_number'] ?? user.phone ?? '0701 234 567';
        farmName = farmResponse?['farm_name'] ?? 'No Farm';
        farmLocation = farmResponse?['farm_location'] ?? 'No Location';
        location = farmLocation;
        loading = false;
      });
    } catch (e) {
      setState(() {
        name = user.email?.split('@').first ?? 'Farmer';
        phone = user.phone ?? '0701 234 567';
        farmName = 'No Farm';
        farmLocation = 'No Location';
        location = farmLocation;
        loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile. Showing defaults.')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'profile'.tr(),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: CustomColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            
          ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          name != null && name!.isNotEmpty
                              ? name![0].toUpperCase()
                              : 'O',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'poultry_farmer'.tr(),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'myfarm_is_in'.tr(
                              namedArgs: {'location': farmLocation ?? ''},
                            ),
                            style: const TextStyle(
                              color: Colors.black26,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'my_number'.tr(namedArgs: {'phone': phone ?? ''}),
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final result =
                            await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  initialName: name,
                                  initialLocation: farmLocation,
                                  initialPhone: phone,
                                ),
                              ),
                            );

                        if (result != null) {
                          setState(() {
                            name = result['name'] as String?;
                            farmLocation = result['location'] as String?;
                            location = farmLocation;
                            phone = result['phone'] as String?;
                          });
                        }
                      },
                      child: Text('edit_profile'.tr(),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  MenuCard(
                    icon: Icons.language,
                    title: 'language_preferences'.tr(),
                    onTap: () =>
                        context.go('/language', extra: {'fromprofile': true}),
                  ),
                  MenuCard(
                    icon: Icons.phone,
                    title: 'add_recovery_phone'.tr(),
                    onTap: () {
                      context.push('/profile/recovery_phone_page');
                    },
                  ),
                  MenuCard(
                    icon: Icons.logout,
                    title: 'logout'.tr(),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => PopUp(
                          title: 'logout_confirmation_title'.tr(),
                          message: 'logout_confirmation_message'.tr(),
                          mainButtonText: 'cancel'.tr(),
                          secondaryButtonText: 'logout'.tr(),
                          onMainAction: () {
                            context.pop();
                          },
                          onsecondaryAction: () async {
                            context.pop(context);
                            await _logout();
                          },
                          icon: SvgPicture.asset(
                            'assets/icons/remove-alert.svg',
                            height: 150,
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                  MenuCard(
                    icon: Icons.delete_outline,
                    title: 'delete_account'.tr(),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => PopUp(
                          title: 'confirm_deletion'.tr(),
                          message: 'deletion_message'.tr(),
                          mainButtonText: 'cancel'.tr(),
                          secondaryButtonText: 'delete'.tr(),
                          onMainAction: () {
                            context.pop(context);
                          },
                          onsecondaryAction: () {},
                          icon: SvgPicture.asset(
                            'assets/icons/remove-alert.svg',
                            height: 150,
                            width: 150,
                            fit: BoxFit.contain,
                            // colorFilter:Colors.red ,
                          ),
                        ),
                      );
                    },
                    iconColor: Colors.red,
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),

      //  bottomNavigationBar: BottomNavigationBar(items: 2),
    );
  }
}

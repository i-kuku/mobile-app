import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/profile/presentation/pages/edit_profile_page.dart';
// import 'package:ikuku/features/profile/presentation/pages/recovery_phone_page.dart';
import 'package:ikuku/features/profile/presentation/widgets/menu_card.dart';
import 'package:ikuku/features/profile/presentation/widgets/pop_up.dart';
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:ikuku/shared/widgets/sync_status_banner.dart';
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
  String? avatarUrl;
  bool loading = true;
  bool _avatarFailed = false;
  StreamSubscription<String>? _changes;

  SyncEngine get _sync => OfflineServices.instance.sync;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _changes = _sync.store.changes
        .where((t) => t == LocalTables.users || t == LocalTables.farms)
        .listen((_) => _loadProfile());
    _sync.refresh();
  }

  @override
  void dispose() {
    _changes?.cancel();
    super.dispose();
  }

  static String? _text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;

  /// Shows the profile saved on this phone; a background sync keeps it
  /// current.
  void _loadProfile() {
    if (!mounted) return;
    final user = Supabase.instance.client.auth.currentUser;
    final userId = _sync.currentUserId;
    final profile = userId == null
        ? null
        : _sync.store.row(LocalTables.users, userId);
    final farm = _sync.store.rows(LocalTables.farms).firstOrNull;

    setState(() {
      name =
          _text(profile?['full_name']) ??
          user?.email?.split('@').first ??
          'Farmer';
      phone = _text(profile?['phone_number']) ?? user?.phone ?? '0701 234 567';
      farmName = _text(farm?['farm_name']) ?? 'No Farm';
      farmLocation = _text(farm?['farm_location']) ?? 'No Location';
      location = farmLocation;
      final newAvatar = _text(profile?['avatar_url']);
      if (newAvatar != avatarUrl) _avatarFailed = false;
      avatarUrl = newAvatar;
      loading = false;
    });
  }

  Future<void> _logout() async {
    // Give unsent changes a last chance to upload.
    if (_sync.pendingCount > 0) await _sync.sync(pull: false);
    final unsent = _sync.pendingCount + _sync.parkedCount;
    if (unsent > 0 && !await _confirmLosingChanges(unsent)) return;

    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      // The session is already gone from this phone; only telling the
      // server failed, and it forgets the session when it expires.
      debugPrint('Could not tell the server about the sign-out: $e');
    }
    await OfflineServices.instance.signedOut();
    if (mounted) context.go('/auth');
  }

  Future<bool> _confirmLosingChanges(int unsent) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('logout_confirmation_title'.tr()),
        content: Text('logout_unsynced_warning'.plural(unsent)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'logout_anyway'.tr(),
              style: const TextStyle(color: CustomColors.errorColor),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _initiateAccountDeletion() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return;

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: user.email!,
        shouldCreateUser: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification code sent to your email.')),
        );

        context.push('/profile/otp_verification_page');
      }
    } catch (e) {
      debugPrint('Could not request a verification code: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
      }
    }
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
                        backgroundImage: avatarUrl != null && !_avatarFailed
                            ? NetworkImage('$avatarUrl')
                            : null,
                        // Offline, the photo can't load; show the initial.
                        onBackgroundImageError:
                            avatarUrl != null && !_avatarFailed
                            ? (_, _) => setState(() => _avatarFailed = true)
                            : null,
                        child: avatarUrl == null || _avatarFailed
                            ? Text(
                                name != null && name!.isNotEmpty
                                    ? name![0].toUpperCase()
                                    : 'O',
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.black54,
                                ),
                              )
                            : null,
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
                                  initialAvatarUrl: avatarUrl,
                                ),
                              ),
                            );

                        if (result != null) {
                          setState(() {
                            name = result['name'] as String?;
                            farmLocation = result['location'] as String?;
                            location = farmLocation;
                            phone = result['phone'] as String?;
                            avatarUrl = result['avatar_url'] as String?;
                          });
                        }
                      },
                      child: Text(
                        'edit_profile'.tr(),
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge!.copyWith(fontSize: 16),
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
                  const _SyncStatusCard(),
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
                            context.pop();
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
                            context.pop();
                          },
                          onsecondaryAction: () async {
                            context.pop();
                            await _initiateAccountDeletion();
                          },
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

/// Whether everything entered on this phone has reached the server.
class _SyncStatusCard extends StatelessWidget {
  const _SyncStatusCard();

  @override
  Widget build(BuildContext context) {
    final sync = OfflineServices.instance.sync;
    return ListenableBuilder(
      listenable: Listenable.merge([sync, sync.connectivity]),
      builder: (context, _) {
        final state = syncBannerStateFor(sync);
        final subtitle = switch (state) {
          null => 'all_changes_uploaded'.tr(),
          SyncBannerState.offline => 'offline_banner'.tr(),
          SyncBannerState.parked => 'parked_banner'.plural(sync.parkedCount),
          SyncBannerState.syncing => 'syncing_banner'.tr(),
          SyncBannerState.pending => 'pending_banner'.plural(sync.pendingCount),
        };
        return Card(
          elevation: 2,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              state == null
                  ? Icons.cloud_done_outlined
                  : state == SyncBannerState.offline
                  ? Icons.cloud_off_outlined
                  : Icons.cloud_upload_outlined,
              color: state == SyncBannerState.parked
                  ? CustomColors.errorColor
                  : CustomColors.primary,
              size: 20,
            ),
            title: Text(
              'sync_status'.tr(),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: CustomColors.text,
                fontSize: 20,
              ),
            ),
            subtitle: Text(subtitle),
            trailing: state == SyncBannerState.pending
                ? TextButton(
                    onPressed: sync.sync,
                    child: Text('upload_now'.tr()),
                  )
                : null,
            onTap: state == SyncBannerState.parked
                ? () => showSyncProblemsDialog(sync)
                : null,
          ),
        );
      },
    );
  }
}

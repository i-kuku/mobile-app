import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/routing/app_router.dart';
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:ikuku/theme/app_theme.dart';

/// What the [SyncStatusBanner] is telling the farmer.
enum SyncBannerState { offline, parked, syncing, pending }

/// The banner to show for [sync], or null when everything is uploaded.
SyncBannerState? syncBannerStateFor(SyncEngine sync) {
  if (sync.currentUserId == null) return null;
  if (!sync.isOnline) return SyncBannerState.offline;
  if (sync.parkedCount > 0) return SyncBannerState.parked;
  if (sync.pendingCount == 0) return null;
  return sync.isSyncing ? SyncBannerState.syncing : SyncBannerState.pending;
}

/// Wraps the app in a strip that says when the phone is offline, when
/// changes are waiting to upload, and when the server refused some.
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key, required this.child, this.sync});

  final Widget child;

  /// Defaults to the app's [OfflineServices].
  final SyncEngine? sync;

  @override
  Widget build(BuildContext context) {
    final sync =
        this.sync ??
        (OfflineServices.isReady ? OfflineServices.instance.sync : null);
    if (sync == null) return child;

    return ListenableBuilder(
      listenable: Listenable.merge([sync, sync.connectivity]),
      builder: (context, _) {
        final state = syncBannerStateFor(sync);
        final media = MediaQuery.of(context);
        // The tree keeps the same shape whether or not the strip shows, so
        // the screens below never lose their state.
        return Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: state == null
                  ? const SizedBox(width: double.infinity)
                  : _Strip(state: state, sync: sync),
            ),
            Expanded(
              child: MediaQuery(
                // The strip already sits below the status bar.
                data: state == null
                    ? media
                    : media.removePadding(removeTop: true),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip({required this.state, required this.sync});

  final SyncBannerState state;
  final SyncEngine sync;

  @override
  Widget build(BuildContext context) {
    final pending = sync.pendingCount;
    final (icon, background, message) = switch (state) {
      SyncBannerState.offline => (
        Icons.cloud_off_outlined,
        CustomColors.text,
        pending == 0
            ? 'offline_banner'.tr()
            : 'offline_banner_pending'.tr(args: ['$pending']),
      ),
      SyncBannerState.parked => (
        Icons.error_outline,
        CustomColors.errorColor,
        'parked_banner'.tr(args: ['${sync.parkedCount}']),
      ),
      SyncBannerState.syncing => (
        Icons.cloud_upload_outlined,
        CustomColors.primary,
        'syncing_banner'.tr(),
      ),
      SyncBannerState.pending => (
        Icons.cloud_upload_outlined,
        CustomColors.primary,
        'pending_banner'.tr(args: ['$pending']),
      ),
    };

    return Material(
      color: background,
      child: SafeArea(
        bottom: false,
        child: InkWell(
          onTap: switch (state) {
            SyncBannerState.parked => () => showSyncProblemsDialog(sync),
            SyncBannerState.pending => () => sync.sync(),
            _ => null,
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                if (state == SyncBannerState.syncing)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
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

/// Explains the changes the server refused and offers to send them again
/// or drop them.
Future<void> showSyncProblemsDialog(SyncEngine sync) async {
  final context = navigatorKey.currentContext;
  if (context == null || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('sync_problem_title'.tr()),
      content: Text('sync_problem_message'.tr(args: ['${sync.parkedCount}'])),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            sync.discardParked();
          },
          child: Text(
            'discard'.tr(),
            style: const TextStyle(color: CustomColors.errorColor),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            sync.retryParked();
          },
          child: Text('try_again'.tr()),
        ),
      ],
    ),
  );
}

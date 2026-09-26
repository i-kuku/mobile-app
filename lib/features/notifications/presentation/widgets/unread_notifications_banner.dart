import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ikuku/features/notifications/model/notifications_model.dart';
import 'package:ikuku/features/notifications/provider/notifications_provider.dart';
import 'package:ikuku/theme/app_theme.dart';

class UnreadNotificationsBanner extends StatefulWidget {
  const UnreadNotificationsBanner({super.key});

  @override
  State<UnreadNotificationsBanner> createState() =>
      _UnreadNotificationsBannerState();
}

class _UnreadNotificationsBannerState
    extends State<UnreadNotificationsBanner> {
  Timer? _timer;
  int _index = 0;
  List<NotificationModel> _queue = [];
  bool _visible = false;
  bool _started = false; 

  void _startCycle(List<NotificationModel> unread) {
    if (_started || unread.isEmpty) return;
    _started = true;

    setState(() {
      _queue = unread;
      _index = 0;
      _visible = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_index >= _queue.length - 1) {
        timer.cancel();
        if (mounted) setState(() => _visible = false);
      } else {
        if (mounted) setState(() => _index++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watching means this widget rebuilds when fetchNotifications() finishes
    // populating the provider, even though it mounted before that happened.
    final unread = context.watch<NotificationsProvider>().unreadNotifications;

    // Try to start the cycle on every build until it successfully starts once.
    // Cheap no-op once _started is true or unread is still empty.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCycle(unread));

    if (!_visible || _queue.isEmpty) return const SizedBox.shrink();

    final languageCode = Localizations.localeOf(context).languageCode;
    final notification = _queue[_index];
    final title = notification.getTitle(languageCode);
    final message = notification.getMessage(languageCode);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        key: ValueKey(notification.id),
        onTap: () {
          context.push('/notifications');
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_active, color: CustomColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
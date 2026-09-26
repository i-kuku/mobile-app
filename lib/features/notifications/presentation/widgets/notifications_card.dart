import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/notifications/model/notifications_model.dart';
import 'package:ikuku/theme/app_theme.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final title = notification.getTitle(languageCode);
    final message = notification.getMessage(languageCode);
    final timeAgo = _getTimeAgo(notification.createdAt);

    final notificationConfig = _getNotificationConfig(notification.type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!notification.isRead) ...[
                    const CircleAvatar(
                      backgroundColor: CustomColors.secondary,
                      radius: 4,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Icon(
                    notificationConfig['icon'],
                    color: notificationConfig['color'],
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),

                    // Action links — navigate based on notification type.
                    if (notification.type == 'missing_record') ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => context.push('/report-entry'),
                        child: const Text(
                          'START RECORDING',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.primary,
                          ),
                        ),
                      ),
                    ] else if (notification.type == 'prediction') ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => context.push('/predictions'),
                        child: const Text(
                          'VIEW PREDICTIONS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getNotificationConfig(String type) {
    switch (type) {
      case 'low_stock':
        return {'icon': Icons.watch_later_rounded, 'color': CustomColors.primary};
      case 'health_tip':
        return {'icon': Icons.health_and_safety, 'color': CustomColors.primary};
      case 'missing_record':
        return {'icon': Icons.edit_note_rounded, 'color': CustomColors.primary};
      case 'prediction':
        return {'icon': Icons.insights, 'color': CustomColors.primary};
      default:
        return {'icon': Icons.notifications_outlined, 'color': CustomColors.primary};
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m';
    return 'Just now';
  }
}
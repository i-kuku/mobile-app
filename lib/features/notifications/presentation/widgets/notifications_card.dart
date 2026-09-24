import 'package:flutter/material.dart';
import 'package:ikuku/features/notifications/model/notifications_model.dart';
import 'package:ikuku/theme/app_theme.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final title = notification.getTitle(languageCode);
    final message = notification.getMessage(languageCode);
    final isLowStock = notification.type == 'low_stock';
    final iconData = isLowStock
        ? Icons.lock_clock
        : Icons.assignment_late_outlined;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : Colors.green,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade200
              : Colors.green.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: iconColor,
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
          ),
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

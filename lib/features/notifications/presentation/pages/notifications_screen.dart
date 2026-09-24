import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart'; // Make sure this import matches your project
import 'package:ikuku/features/notifications/presentation/widgets/notifications_card.dart';
import 'package:ikuku/features/notifications/provider/notifications_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Explicitly specify the InventoryProvider type
      final lowStockItems = context.read<InventoryProvider>().lowStockFeeds;
      
      // 2. Explicitly specify the NotificationsProvider type and match parameter names
      context.read<NotificationsProvider>().fetchNotifications(
            lowStockFeeds: lowStockItems,
            hasRecordedToday: true, // Set to true so it doesn't try to insert duplicates while testing your DB rows
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final notifications = provider.notifications;
    final isLoading = provider.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          'notifications'.tr(),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CustomColors.text,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: () async {
                final lowStockItems = context.read<InventoryProvider>().lowStockFeeds;

                await context.read<NotificationsProvider>().fetchNotifications(
                      lowStockFeeds: lowStockItems,
                      hasRecordedToday: true,
                    );
              },
              color: Colors.green,
              child: notifications.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return NotificationCard(
                          notification: notification,
                          onTap: () {
                            // Optional: mark as read logic when tapped
                          },
                        );
                      },
                    ),
            ),
    );
  }

  // Empty State Matching Design
  Widget _buildEmptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/icons/rafiki.svg'),
                  const SizedBox(height: 32),
                  Text(
                    "you_re_all_caught_up".tr(),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 20,
                      color: CustomColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "come_back_later_for_reminders_health_tips_and_predictions"
                        .tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 20,
                      color: CustomColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton.icon(
                      onPressed: () {
                        context.go('/');
                      },
                      iconAlignment: IconAlignment.end,
                      label: Text(
                        "back_to_dashboard".tr(),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 20,
                          color: CustomColors.primary,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_forward,
                        color: CustomColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

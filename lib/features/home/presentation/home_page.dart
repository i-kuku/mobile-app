import 'package:flutter/material.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/features/home/presentation/widgets/analytics.dart';
import 'package:ikuku/features/home/presentation/widgets/quick_actions_container.dart';
import 'package:ikuku/features/home/presentation/widgets/salutation_widget.dart';
import 'package:ikuku/features/home/provider/analytics_provider.dart';
import 'package:ikuku/features/home/provider/tutorial_provider.dart';
import 'package:ikuku/features/notifications/presentation/widgets/unread_notifications_banner.dart';
import 'package:ikuku/features/notifications/provider/notifications_provider.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (mounted) {
        Provider.of<TutorialProvider>(
          context,
          listen: false,
        ).maybeShowTutorial(context);
        Provider.of<AnalyticsProvider>(context, listen: false).fetchSummary();
      }
      if (!mounted) return;
      final inventoryProvider = Provider.of<InventoryProvider>(
        context,
        listen: false,
      );
      final batchProvider = Provider.of<BatchProvider>(context, listen: false);
      final farmReportProvider = Provider.of<FarmReportProvider>(context, listen: false);

      if (inventoryProvider.inventory.isEmpty) {
        await inventoryProvider.fetchInventory();
      }
      if (batchProvider.batches.isEmpty) {
        await batchProvider.fetchBatches();
      }
      final hasRecordedToday = await farmReportProvider.hasRecordedToday();

      if (!mounted) return;

      await Provider.of<NotificationsProvider>(
        context,
        listen: false,
      ).fetchNotifications(
        lowStockFeeds: inventoryProvider.lowStockFeeds,
        hasRecordedToday: hasRecordedToday,
        batches: batchProvider.batches,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15,
        children: const [
          SalutationWidget(),
          UnreadNotificationsBanner(),
          Analytics(),
          QuickActionsContainer(),
        ],
      ),
    );
  }
}

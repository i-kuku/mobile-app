import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/Inventory/presentation/widgets/inventory_list_template.dart';

class FeedsPage extends StatelessWidget {
  const FeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InventoryListTemplate(
      title: 'feeds_description'.tr(), 
      emptyTitle: "no_feeds_title".tr(), 
      tiptext: 'feeds_adjust_tip'.tr(), 
      category: 'feeds',
      );
  }
}
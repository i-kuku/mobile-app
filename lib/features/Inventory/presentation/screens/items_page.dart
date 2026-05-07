import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/Inventory/presentation/widgets/inventory_list_template.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InventoryListTemplate(
      title: "items_description".tr(), 
      emptyTitle: "no_items_title".tr(), 
      tiptext: "items_adjust_tip".tr(), 
      category: 'others'
      );
  }
}
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/Inventory/presentation/widgets/inventory_list_template.dart';

class MedicinesPage extends StatelessWidget {
  const MedicinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InventoryListTemplate(
      title: "medicines_description".tr(), 
      emptyTitle: "no_medicine_title".tr(), 
      tiptext:"medicine_adjust_tip".tr() , 
      category: 'medicines', 
      );
  }
}
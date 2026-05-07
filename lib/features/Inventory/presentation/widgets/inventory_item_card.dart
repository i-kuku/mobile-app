import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/Inventory/presentation/widgets/add_item_dialog.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;

  const InventoryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade600, width: 0.43),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${item.quantity} ${item.unit}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CustomColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.price} ksh',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CustomColors.textDisabled,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
             Row(
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color:CustomColors.secondary, 
                      size: 28,
                    ),
                    onPressed: () => context.read<InventoryProvider>().incrementQuantity(item.id),
                ),
                SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () =>addItemDialog(context, item.category,itemToEdit: item),
                      child: Text(
                        'edit'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ),
              ],)
            ],
          )
        ],
      ),
    );
  }
}

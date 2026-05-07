import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/Inventory/presentation/widgets/add_item_dialog.dart';
import 'package:ikuku/features/Inventory/presentation/widgets/inventory_item_card.dart';
import 'package:ikuku/features/Inventory/presentation/widgets/inventory_tip.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class InventoryListTemplate extends StatelessWidget{
  final String title;
  final String emptyTitle;
  final String tiptext;
  final String category;

  const InventoryListTemplate({
    super.key,
    required this.title,
    required this.emptyTitle,
    required this.tiptext,
    required this.category
  });

  @override
  Widget build(BuildContext context) {
    final provider =context.watch<InventoryProvider>();

    final items= category =="feeds"?
     provider.feeds:category=="medicines"? 
     provider.medicines : provider.others;

     bool isEmpty = items.isEmpty;

     return Scaffold(
      appBar: AppBar(
         elevation: 0,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => context.pop(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               SizedBox(width: 8),
              Icon(Icons.arrow_back, color: Colors.black, size: 18),
               SizedBox(width: 4),
              Text(
                "back".tr(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding:EdgeInsets.symmetric(horizontal: 16,vertical: 24),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 26),
            Text(isEmpty? emptyTitle :title,
            style:Theme.of(context).textTheme.titleLarge?.copyWith(color:CustomColors.text,fontSize: 25),
            ),
             SizedBox(height: 16),
             InventoryTip(message: tiptext),
             SizedBox(height: 24),

             Expanded(
              child: isEmpty?
              _buildEmptyState(context):
              _buildActiveState(items),
              )
          ],
          )
      ),
      floatingActionButton:isEmpty? null : FloatingActionButton(
        onPressed: () {
          addItemDialog(context, category);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: CustomColors.buttonGradient,
          ),
        
          child: const Icon(Icons.add,color: Colors.black)),
      )
     );
}
Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.primary, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => addItemDialog(context, category),
          child: Text(
            'add ${category.toUpperCase()}'.tr(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveState(List<InventoryItem> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => InventoryItemCard(item: items[index]),
    );
      }
}
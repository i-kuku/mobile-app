import 'package:flutter/material.dart';
import 'package:ikuku/features/Inventory/presentation/screens/inventory_hub_page.dart';
import 'package:ikuku/theme/app_theme.dart';

class InventoryCategoryCard extends StatelessWidget {
  final InventoryCategory category;
  final VoidCallback onTap;

  const InventoryCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap:onTap,
        borderRadius: BorderRadius.circular(8),
        child:Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
          border:Border.all(color: Colors.grey.shade300,width: 0.43),
          borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment:MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[
              SizedBox(height: 32,
              child:category.icon,
              ),
              SizedBox(height: 8),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color:CustomColors.text,fontSize:20,fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                category.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color:CustomColors.text,fontSize:14,fontWeight: FontWeight.w400),
              ),
            ]
          )
        )
      )
    );
  }
}

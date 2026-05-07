import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/Inventory/presentation/widgets/inventory_category_card.dart';

class InventoryCategory{
  final String name;
  final String description;
  final Widget icon;
  final String route;

  InventoryCategory({
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
  });
}

class InventoryHubPage extends StatelessWidget {
 InventoryHubPage({super.key});
  final List<InventoryCategory> categories = [
    InventoryCategory(
      name: 'feed'.tr(),
      description: 'feeds_description'.tr(),
      icon: SvgPicture.asset('assets/icons/feeds.svg'),
      route: '/inventory/feedspage',
    ),
    InventoryCategory(
      name: 'medicine'.tr(),
      description: 'medicines_description'.tr(),
      icon: SvgPicture.asset('assets/icons/vaccines.svg'),
      route: '/inventory/medicines',
    ),
    InventoryCategory(
      name: 'other'.tr(),
      description: 'items_description'.tr(),
      icon: SvgPicture.asset('assets/icons/others.svg'),
      route: '/inventory/others',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('my_inventory'.tr(),
        style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
            },
          ),
        ]
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 50),
        itemCount: categories.length,
        separatorBuilder:(context,index) => const SizedBox(height: 16),
        itemBuilder:(context, index) {
          final item = categories[index];
          return InventoryCategoryCard(
            category:item,
            onTap: ()=>context.push(item.route),
          );
        },
      ),
    );
  }
}
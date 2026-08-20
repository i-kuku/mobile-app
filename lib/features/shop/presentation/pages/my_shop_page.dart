import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/shop/presentation/widgets/total_sales_card.dart';
import 'package:ikuku/theme/app_theme.dart';

class MyShopPage extends StatelessWidget {
  const MyShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        centerTitle: true,
        title: Text('my_shop'.tr()),
        leading: Icon(Icons.arrow_back,color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TotalSalesCard(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('latest_sales'.tr(),style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 10,color: CustomColors.text),),
                Text('all_sales'.tr(),style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 10,color: CustomColors.text),)
              ],
            )
          ],
        ),
      ),
    );
  }
}

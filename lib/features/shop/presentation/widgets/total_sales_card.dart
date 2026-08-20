import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/theme/app_theme.dart';

class TotalSalesCard extends StatefulWidget {
  const TotalSalesCard({super.key});

  @override
  State<TotalSalesCard> createState() => _TotalSalesCardState();
}

class _TotalSalesCardState extends State<TotalSalesCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(20.0),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.paid,size: 28,color: CustomColors.primary),
          SizedBox(height: 16),
          Text('total_sales'.tr(),
          style:Theme.of(context).textTheme.titleMedium!.copyWith(color:CustomColors.text,fontSize: 16)),
          Text('ksh',
          style:Theme.of(context).textTheme.titleLarge!.copyWith(color:CustomColors.text,fontSize: 20)),
          SizedBox(height: 16),
          TextButton(
            child: Container(
              height: 35,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: CustomColors.text),
                  SizedBox(width: 8),
                  Text("record_sales".tr(), style: Theme.of(context).textTheme.titleMedium!.copyWith(color:CustomColors.text,fontSize: 16)),
                ],
              ),
            ),
            onPressed: (){
              context.push('/sales-page');
            },
          )
        ]
      )
    );
  }
}
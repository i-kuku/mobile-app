import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ikuku/theme/app_theme.dart';

class TotalSalesCard extends StatelessWidget {
  final String amount;
  final VoidCallback onRecordSale;

  const TotalSalesCard({
    super.key,
    required this.amount,
    required this.onRecordSale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/icons/icons-money.svg', height: 18),
          SizedBox(height: 10),
          Text(
            "today_total_sales".tr(),
            style: TextStyle(color: Colors.grey.shade600,fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            amount,
            style:TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: CustomColors.buttonGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: onRecordSale,
                icon: Icon(Icons.add, color: Colors.black),
                label:Text(
                  'record_sale'.tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

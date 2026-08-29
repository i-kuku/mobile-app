import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/theme/app_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final VoidCallback onTap;
  const ConfirmationDialog({
    super.key, 
    required this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 333,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/shop-success.svg'),
              SizedBox(height: 10),
              Text("your_sale_has_been_recorded".tr()),
              SizedBox(height: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                           color: Colors.lightGreen,
                           width: 2.0,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: () {
                        context.pop();
                      },
                      child: Text('back'.tr()),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: onTap,
                      
        
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.lightGreen,
                      ),
                      child: Text('save'.tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

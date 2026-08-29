import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RecordSaleButton extends StatelessWidget {
  final VoidCallback onTap;
  const RecordSaleButton({
    super.key,
    required this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightGreen,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'record_sale'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );;
  }
}
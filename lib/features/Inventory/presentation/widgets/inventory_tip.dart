import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

class InventoryTip extends StatelessWidget {
  final String message;
  final String imagePath;

  const InventoryTip({
    super.key,
    required this.message,
    this.imagePath='assets/icons/tip-chicken.png',
    });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The Hen Icon/Image
          Image.asset(
            imagePath,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 12),
          // The Tip Text
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: CustomColors.textDisabled,
                height: 1.4, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
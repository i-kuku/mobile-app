import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

class SelectionCard extends StatelessWidget {
  final Widget? icon;
  final String label;
  final VoidCallback onTap;
  const SelectionCard({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 150,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.white,
       borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700, width: 0.43),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            child: icon,
          ),
           
          Text(label, style: TextStyle(color: CustomColors.text)),
        ],
      ),
    );
  }
}

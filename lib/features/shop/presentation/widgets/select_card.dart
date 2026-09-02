import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

class SelectCard extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback onTap;
  final bool isSelected;

  const SelectCard({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    required this.isSelected,
  });

  Color _getPrimaryColor() {
    switch (label.toLowerCase().trim()) {
      case 'chicken':
        return CustomColors.primary;
      case 'eggs':
        return Colors.orange;
      case 'manure':
        return Colors.lightGreen.shade700;
      default:
        return CustomColors.primary;
    }
  }

  Color _getBackgroundColor() {
    switch (label.toLowerCase().trim()) {
      case 'chicken':
        return Colors.lightGreen.shade50;
      case 'eggs':
        return Colors.yellow.shade100;
      case 'manure':
        return Colors.greenAccent.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _getPrimaryColor();
    final activeBgColor = _getBackgroundColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          // Uses the light background color when selected, white when unselected
          color: isSelected ? activeBgColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade600,
            width: isSelected ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: isSelected
                  ? activeColor
                  : Colors.grey.shade300,
              radius: 15,
              child: icon,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? activeColor : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

class SelectCard extends StatelessWidget {
  final String label;

  /// What the card stands for ('chicken', 'eggs' or 'manure'), which sets its
  /// colors. Defaults to [label], which only works untranslated.
  final String? type;
  final Widget? icon;
  final VoidCallback onTap;
  final bool isSelected;

  const SelectCard({
    super.key,
    required this.label,
    this.type,
    this.icon,
    required this.onTap,
    required this.isSelected,
  });

  String get _kind => (type ?? label).toLowerCase().trim();

  Color _getPrimaryColor() {
    switch (_kind) {
      case 'chicken':
        return CustomColors.primary;
      case 'eggs':
        return CustomColors.secondary;
      case 'manure':
        return Colors.lightGreen.shade300;
      default:
        return CustomColors.primary;
    }
  }

  Color _getBackgroundColor() {
    switch (_kind) {
      case 'chicken':
        return Color(0xFFEFFFF4);
      case 'eggs':
        return Colors.yellow.shade50;
      case 'manure':
        return Color(0xFFEFFFF4)
        ;
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
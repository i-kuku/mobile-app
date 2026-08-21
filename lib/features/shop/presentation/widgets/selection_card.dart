import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

enum SaleType { chicken, eggs, manure }

class SaleTypeSelectionCard extends StatelessWidget {
  final SaleType selectedType;
  final ValueChanged<SaleType> onChanged;

  const SaleTypeSelectionCard({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  static const _config = {
    SaleType.chicken: (
      label: 'Chicken',
      icon: Icons.pets,
      color: CustomColors.primary,
      bg: Color(0xFFEAF7EC),
    ),
    SaleType.eggs: (
      label: 'Eggs',
      icon: Icons.egg,
      color: CustomColors.primary,
      bg: Color(0xFFEAF7EC),
    ),
    SaleType.manure: (
      label: 'Manure',
      icon: Icons.shopping_bag_outlined,
      color: CustomColors.primary,
      bg: Color(0xFFEAF7EC),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What have You Sold?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: SaleType.values.map((type) {
            final isLast = type == SaleType.values.last;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 8),
                child: _chip(type),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _chip(SaleType type) {
    final cfg = _config[type]!;
    final isSelected = type == selectedType;

    return InkWell(
      onTap: () => onChanged(type),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cfg.bg : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? cfg.color : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              cfg.icon,
              size: 16,
              color: isSelected ? cfg.color : Colors.grey,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                cfg.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? cfg.color : Colors.grey.shade700,
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

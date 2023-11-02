import 'package:flutter/material.dart';
import 'package:ikuku/theme/colors.dart';

class LanguageToggleItem extends StatelessWidget {
  final String title;
  final String groupValue;
  final bool isActive;
  final VoidCallback? onTap;
  final Function(String? value)? onChanged;

  const LanguageToggleItem(
      {super.key,
      required this.title,
      required this.groupValue,
      required this.isActive,
      required this.onTap,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: isActive
              ? primaryAlt.withOpacity(0.1)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        tileColor: Theme.of(context).primaryColor,
        onTap: onTap,
        trailing:
            Radio(value: title, groupValue: groupValue, onChanged: onChanged),
      ),
    );
  }
}

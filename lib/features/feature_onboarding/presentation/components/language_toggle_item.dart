import 'package:flutter/material.dart';
import 'package:ikuku/theme/colors.dart';

class LanguageToggleItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback? onTap;

  const LanguageToggleItem({super.key, required this.title, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        trailing: Radio(value: title, groupValue: title, onChanged: (value){}),
      ),
    );
  }
}

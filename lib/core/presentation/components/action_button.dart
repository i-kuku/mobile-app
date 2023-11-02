import 'package:flutter/material.dart';
import 'package:ikuku/theme/colors.dart';

class ActionButton extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback onTap;

  const ActionButton(
      {super.key,
      required this.text,
      this.isLoading = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100), gradient: gradient),
        child: Center(
          child: Text(text.toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

class Dropdown extends StatelessWidget {
  final Widget child;

  const Dropdown({
    super.key,
    required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
      decoration:BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CustomColors.primary)
      ),
      child: child,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ikuku/theme/app_theme.dart';

class AnalyticsCard extends StatelessWidget {
  final String name;
  final String icon;
  final String value;
  const AnalyticsCard({
    super.key,
    required this.name,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.bounceInOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(fontSize: 14, color: CustomColors.text),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: CustomColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

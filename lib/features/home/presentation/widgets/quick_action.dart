import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/home/data/model/quick_action.dart';
import 'package:ikuku/shared/utils/toaster.dart';
import 'package:ikuku/theme/app_theme.dart';

class QuickAction extends StatelessWidget {
  final QuickActionModel action;
  const QuickAction({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      key: action.targetKey,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          if (action.route == null) {
            showToast("Coming soon!");
          } else {
            context.push(action.route!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: CustomColors.secondary,
                child: SizedBox(width: 45, height: 45, child: action.icon),
              ),
              const SizedBox(height: 10),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: CustomColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

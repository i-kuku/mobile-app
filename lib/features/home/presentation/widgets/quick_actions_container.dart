import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/home/data/data/quick_action.dart';
import 'package:ikuku/features/home/presentation/widgets/quick_action.dart';

class QuickActionsContainer extends StatelessWidget {
  const QuickActionsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 10,
      children: [
        Text(
          'quick_actions'.tr(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quickActions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) =>
              QuickAction(action: quickActions[index]),
        ),
      ],
    );
  }
}

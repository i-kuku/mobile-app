import 'package:flutter/material.dart';
import 'package:ikuku/features/home/presentation/widgets/tutorial_card_action.dart';
import 'package:ikuku/features/home/provider/tutorial_provider.dart';
import 'package:ikuku/theme/app_theme.dart';

import 'package:provider/provider.dart';

class TutorialCard extends StatelessWidget {
  final String title;
  final String message;

  const TutorialCard({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, provider, child) {
        final int totalSteps = provider.totalSteps;

        final currentStep = provider.currentStep;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(totalSteps, (index) {
                  final isCompleted = index < currentStep;
                  final isCurrent = index == currentStep - 1;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < totalSteps - 1 ? 6 : 0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isCompleted || isCurrent
                            ? CustomColors.primary
                            : Colors.grey[300],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              // Step counter
              Text(
                'Step $currentStep of $totalSteps',
                style: TextStyle(
                  fontSize: 12,
                  color: CustomColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: CustomColors.text.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 16),
              TutorialCardAction(),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ikuku/features/home/provider/tutorial_provider.dart';
import 'package:ikuku/theme/app_theme.dart';

import 'package:provider/provider.dart';

class TutorialCardAction extends StatelessWidget {
  const TutorialCardAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => provider.tutorialCoachMark?.finish(),
                style: TextButton.styleFrom(
                  foregroundColor: CustomColors.textDisabled,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Skip",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextButton(
                onPressed: () {
                  provider.tutorialCoachMark?.next();
                  provider.nextStep();
                },
                style: TextButton.styleFrom(
                  foregroundColor: CustomColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Continue",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: CustomColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

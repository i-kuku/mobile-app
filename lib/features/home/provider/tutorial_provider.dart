import 'package:flutter/material.dart';
import 'package:ikuku/features/home/data/data/candidate_config.dart';
import 'package:ikuku/features/home/presentation/widgets/tutorial_card.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialProvider with ChangeNotifier {
  TutorialCoachMark? _tutorialCoachMark;
  final List<TargetFocus> _targets = [];

  int _currentStep = 1;

  int get currentStep => _currentStep;

  int get totalSteps => candidateConfigs.length;

  TutorialCoachMark? get tutorialCoachMark => _tutorialCoachMark;

  Future<void> maybeShowTutorial(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenTutorial = prefs.getBool("tutorials") ?? false;

      debugPrint('[DashboardPage] Tutorial seen: $hasSeenTutorial');
      if (hasSeenTutorial) return;

      if (context.mounted) {
        _showTutorial(context);
      }
      await prefs.setBool("tutorials", true);
    } catch (_) {}
  }

  void _showTutorial(BuildContext context) {
    _targets.clear();
    notifyListeners();
    for (final config in candidateConfigs) {
      if (config.key.currentContext == null) {
        debugPrint(
          '[DashboardPage] Tutorial target "${config.id}" has no context yet, skipping.',
        );
        continue;
      }

      _targets.add(
        TargetFocus(
          identify: config.id,
          keyTarget: config.key,
          contents: [
            TargetContent(
              align: config.align,
              child: TutorialCard(title: config.title, message: config.message),
            ),
          ],
        ),
      );
    }

    if (_targets.isEmpty) {
      debugPrint(
        '[DashboardPage] No tutorial targets available, not showing tour.',
      );
      return;
    }

    _tutorialCoachMark = TutorialCoachMark(
      targets: _targets,
      colorShadow: Colors.black.withValues(alpha: 0.7),
      textSkip: 'Skip',
      paddingFocus: 8,
      opacityShadow: 0.8,
      onClickTarget: (target) {
        nextStep();
      },
      onClickOverlay: (target) {
        nextStep();
      },
      onFinish: () {
        _currentStep = 1;
        notifyListeners();
      },
      onSkip: () {
        _currentStep = 1;
        notifyListeners();
        return true;
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        _tutorialCoachMark?.next();
        nextStep();
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!context.mounted) return;
      _tutorialCoachMark?.show(context: context);
    });
  }

  void nextStep() {
    if (_currentStep < totalSteps) {
      _currentStep++;
      notifyListeners();
    }
  }
}

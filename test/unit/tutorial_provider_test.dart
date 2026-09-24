import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/home/data/data/candidate_config.dart';
import 'package:ikuku/features/home/provider/tutorial_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('totalSteps matches the number of tutorial targets', () {
    expect(TutorialProvider().totalSteps, candidateConfigs.length);
  });

  test('nextStep advances and stops at the last step', () {
    final provider = TutorialProvider();
    var notifications = 0;
    provider.addListener(() => notifications++);

    expect(provider.currentStep, 1);
    for (var i = 0; i < candidateConfigs.length + 3; i++) {
      provider.nextStep();
    }
    expect(provider.currentStep, candidateConfigs.length);
    expect(notifications, candidateConfigs.length - 1);
  });

  testWidgets('maybeShowTutorial does nothing once the tutorial was seen',
      (tester) async {
    SharedPreferences.setMockInitialValues({'tutorials': true});
    final provider = TutorialProvider();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    await provider.maybeShowTutorial(tester.element(find.byType(SizedBox)));

    expect(provider.tutorialCoachMark, isNull);
  });

  testWidgets(
      'maybeShowTutorial marks the tutorial as seen and skips when no '
      'targets are on screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = TutorialProvider();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    await provider.maybeShowTutorial(tester.element(find.byType(SizedBox)));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('tutorials'), isTrue);
    expect(provider.tutorialCoachMark, isNull);
  });
}

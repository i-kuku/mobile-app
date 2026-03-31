import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ikuku/features/splash/splash_screen.dart';
import 'package:ikuku/shared/widgets/status_feedback_widget.dart';

void main() {
  // Required for easy_localization to work in tests
  shredFreeTest() => TestWidgetsFlutterBinding.ensureInitialized();

  group('Splash Screen', () {
    testWidgets('Expect the farmer image to be visible', (
      WidgetTester tester,
    ) async {
      // 1. Wrap the widget in a MaterialApp and EasyLocalization mock if necessary
      // If SplashScreen uses context.tr(), it MUST be wrapped in EasyLocalization
      await tester.pumpWidget(MaterialApp(home: StatusFeedback(bodyText: "Text",buttonLabel: "label",heading: "heading",imagePath: "assets/icons/MAIN LOGO.png",onButtonPressed: (){},statusType: StatusType.success,)));

      // 2. Wait for animations to finish
      await tester.pumpAndSettle();

      // 3. Make sure this key matches exactly what is in splash_screen.dart
      // Change 'logo-image' to 'farmer-image' if that is what you used in the UI
      final logo = find.byKey(const Key('image-svg'));

      expect(logo, findsOneWidget);
    });

    testWidgets('Expect the AnimatedBuilder to be visible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: StatusFeedback(
            bodyText: "Text",
            buttonLabel: "label",
            heading: "heading",
            imagePath: "assets/icons/MAIN LOGO.png",
            onButtonPressed: () {},
            statusType: StatusType.success,
          ),
        ));
      await tester.pumpAndSettle();

      final getAnimationBuilder = find.byType(ElevatedButton);
      expect(getAnimationBuilder, findsAtLeastNWidgets(1));
    });
  });
}

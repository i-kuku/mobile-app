import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/shared/widgets/status_feedback_widget.dart';

void main() {
  // Required for easy_localization to work in tests

  group('Splash Screen', () {
    testWidgets('Expect the main logo to be visible', (
      WidgetTester tester,
    ) async {
      // 1. Wrap the widget in a MaterialApp and EasyLocalization mock if necessary
      // If SplashScreen uses context.tr(), it MUST be wrapped in EasyLocalization
      await tester.pumpWidget(MaterialApp(home: StatusFeedback(bodyText: "Text",buttonLabel: "label",heading: "heading",imagePath: "assets/icons/MAIN LOGO.png",onButtonPressed: (){},statusType: StatusType.success,)));

      await tester.pumpAndSettle();

   
      final logo = find.byKey(const Key('image-svg'));

      expect(logo, findsOneWidget);
    });

    testWidgets('Expect the Elevated button to be visible', (
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

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/feature_onboarding/presentation/screens/welcome_screen.dart';

import 'package:ikuku/main.dart';

void main() {

  group('Welcome Screen', () {

    testWidgets('Expect the farmer image to be visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final logo = find.byKey(const Key('farmer-image'));
      expect(logo, findsOneWidget);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:ikuku/main.dart';

void main() {
  testWidgets('Welcome Message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome to I-Kuku'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/auth/presentation/components/sign_in_widget.dart';
import 'package:ikuku/features/auth/presentation/components/sign_up_widget.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:ikuku/routing/app_router.dart';
import 'package:ikuku/shared/utils/toaster.dart';
import 'package:provider/provider.dart';

import '../helpers/test_app.dart';

void main() {
  final email = TextEditingController();
  final password = TextEditingController();
  final repeat = TextEditingController();

  for (final (name, build) in [
    (
      'SignInWidget',
      () => SignInWidget(emailController: email, passwordController: password),
    ),
    (
      'SignUpWidget',
      () => SignUpWidget(
        emailController: email,
        passwordController: password,
        repeatPasswordController: repeat,
      ),
    ),
  ]) {
    testWidgets('$name keeps focus when its parent rebuilds', (tester) async {
      final rebuild = ValueNotifier(0);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: wrap(
            ValueListenableBuilder<int>(
              valueListenable: rebuild,
              // A fresh widget instance on every rebuild, as AuthPage does.
              builder: (_, _, _) => build(),
            ),
          ),
        ),
      );

      final passwordField = find.byType(EditableText).at(1);
      await tester.tap(passwordField);
      await tester.pump();
      expect(
        tester.widget<EditableText>(passwordField).focusNode.hasFocus,
        isTrue,
      );

      rebuild.value++;
      await tester.pump();

      expect(
        tester.widget<EditableText>(passwordField).focusNode.hasFocus,
        isTrue,
      );
    });

    testWidgets('$name moves from email to password on "next"', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: wrap(build()),
        ),
      );

      await tester.tap(find.byType(EditableText).first);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).at(1))
            .focusNode
            .hasFocus,
        isTrue,
      );
    });
  }

  testWidgets('showToast is a no-op before the navigator exists', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    expect(navigatorKey.currentContext, isNull);

    showToast('Saved');
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

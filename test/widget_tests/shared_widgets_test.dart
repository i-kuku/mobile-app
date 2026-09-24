import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/shared/widgets/custom_dialog.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/shared/widgets/loading_button.dart';
import 'package:ikuku/shared/widgets/text_field_widget.dart';

import '../helpers/test_app.dart';

void main() {
  group('LoadingButton', () {
    for (final (type, finder) in [
      (LoadingButtonType.elevated, find.byType(ElevatedButton)),
      (LoadingButtonType.outlined, find.byType(OutlinedButton)),
      (LoadingButtonType.text, find.byType(TextButton)),
    ]) {
      testWidgets('$type renders its child and fires onPressed',
          (tester) async {
        var taps = 0;
        await tester.pumpWidget(wrap(LoadingButton(
          type: type,
          onPressed: () => taps++,
          child: const Text('Save'),
        )));

        expect(finder, findsOneWidget);
        await tester.tap(find.text('Save'));
        expect(taps, 1);
      });

      testWidgets('$type shows a spinner and is disabled while loading',
          (tester) async {
        var taps = 0;
        await tester.pumpWidget(wrap(LoadingButton(
          type: type,
          isLoading: true,
          onPressed: () => taps++,
          child: const Text('Save'),
        )));

        expect(find.text('Save'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.tap(finder);
        expect(taps, 0);
      });
    }
  });

  group('FeatureButton', () {
    testWidgets('upper-cases the label, shows the icon and taps',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(wrap(FeatureButton(
        label: 'batches',
        icon: Icons.egg,
        onTap: () => taps++,
      )));

      expect(find.text('BATCHES'), findsOneWidget);
      expect(find.byIcon(Icons.egg), findsOneWidget);
      await tester.tap(find.text('BATCHES'));
      expect(taps, 1);
    });

    testWidgets('renders without an icon', (tester) async {
      await tester.pumpWidget(wrap(FeatureButton(label: 'x', onTap: () {})));
      expect(find.byType(Icon), findsNothing);
    });
  });

  group('CustomDialog', () {
    testWidgets('uses the primary colour for success and red for errors',
        (tester) async {
      await tester.pumpWidget(wrap(CustomDialog(
        title: 'Oops',
        message: 'Failed',
        isSuccess: false,
        onOkPressed: () {},
      )));
      expect(tester.widget<Text>(find.text('Oops')).style?.color, Colors.red);
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('showCustomDialog closes the dialog then runs the callback',
        (tester) async {
      var okPressed = false;
      await tester.pumpWidget(wrap(Builder(
        builder: (context) => TextButton(
          onPressed: () => showCustomDialog(
            context: context,
            title: 'Saved',
            message: 'Batch saved',
            isSuccess: true,
            onOkPressed: () => okPressed = true,
          ),
          child: const Text('open'),
        ),
      )));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Batch saved'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomDialog), findsNothing);
      expect(okPressed, isTrue);
    });
  });

  group('TextFieldWidget', () {
    late GlobalKey<FormState> formKey;
    late TextEditingController controller;

    setUp(() {
      formKey = GlobalKey<FormState>();
      controller = TextEditingController();
    });

    Future<String?> validate(
      WidgetTester tester,
      TextFieldWidget field,
      String text,
    ) async {
      await tester.pumpWidget(wrap(Form(key: formKey, child: field)));
      controller.text = text;
      formKey.currentState!.validate();
      await tester.pump();
      final error = find.descendant(
        of: find.byType(TextFormField),
        matching: find.byWidgetPredicate(
            (w) => w is Text && w.data != null && w.data!.contains(' ')),
      );
      final texts = tester.widgetList<Text>(error).map((t) => t.data).toList();
      return texts.isEmpty ? null : texts.last;
    }

    testWidgets('required field reports the label', (tester) async {
      final error = await validate(
        tester,
        TextFieldWidget(
          controller: controller,
          focusNode: FocusNode(),
          hintText: 'hint',
          labelText: 'Farm name',
          isLoading: false,
        ),
        '',
      );
      expect(error, 'Farm name is required');
    });

    testWidgets('optional field with no rules passes when empty',
        (tester) async {
      await tester.pumpWidget(wrap(Form(
        key: formKey,
        child: TextFieldWidget(
          controller: controller,
          focusNode: FocusNode(),
          hintText: 'Notes',
          isLoading: false,
          isRequired: false,
        ),
      )));
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('minimumCharacters is enforced', (tester) async {
      final error = await validate(
        tester,
        TextFieldWidget(
          controller: controller,
          focusNode: FocusNode(),
          hintText: 'Name',
          isLoading: false,
          minimumCharacters: 3,
        ),
        'ab',
      );
      expect(error, 'Name must be at least 3 characters');
    });

    testWidgets('email fields validate format and show the email icon',
        (tester) async {
      final error = await validate(
        tester,
        TextFieldWidget(
          controller: controller,
          focusNode: FocusNode(),
          hintText: 'Email',
          isLoading: false,
          isEmail: true,
        ),
        'not an email',
      );
      expect(error, 'Enter a valid email');
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('password fields validate length', (tester) async {
      final error = await validate(
        tester,
        TextFieldWidget(
          controller: controller,
          focusNode: FocusNode(),
          hintText: 'Password',
          isLoading: false,
          isPassword: true,
        ),
        '123',
      );
      expect(error, 'Password must be at least 6 characters');
    });

    testWidgets('password visibility toggles', (tester) async {
      await tester.pumpWidget(wrap(TextFieldWidget(
        controller: controller,
        focusNode: FocusNode(),
        hintText: 'Password',
        isLoading: false,
        isPassword: true,
      )));

      EditableText editable() =>
          tester.widget<EditableText>(find.byType(EditableText));

      expect(editable().obscureText, isTrue);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(editable().obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('username fields show the person icon', (tester) async {
      await tester.pumpWidget(wrap(TextFieldWidget(
        controller: controller,
        focusNode: FocusNode(),
        hintText: 'Username',
        isLoading: false,
        isUsername: true,
      )));
      expect(find.byIcon(Icons.person_outline_outlined), findsOneWidget);
    });

    testWidgets('onChanged receives typed text', (tester) async {
      String? changed;
      await tester.pumpWidget(wrap(TextFieldWidget(
        controller: controller,
        focusNode: FocusNode(),
        hintText: 'Name',
        isLoading: false,
        onChanged: (v) => changed = v,
      )));
      await tester.enterText(find.byType(TextFormField), 'Kuku');
      expect(changed, 'Kuku');
    });

    testWidgets('submitting moves focus to the next field', (tester) async {
      final first = FocusNode();
      final next = FocusNode();
      await tester.pumpWidget(wrap(Column(children: [
        TextFieldWidget(
          controller: controller,
          focusNode: first,
          nextFocusNode: next,
          hintText: 'First',
          isLoading: false,
        ),
        TextFieldWidget(
          controller: TextEditingController(),
          focusNode: next,
          hintText: 'Second',
          isLoading: false,
        ),
      ])));

      await tester.tap(find.byType(TextFormField).first);
      await tester.pump();
      expect(first.hasFocus, isTrue);
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(next.hasFocus, isTrue);
    });
  });
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/batches/presentation/Widgets/pop_up.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Empty translation map so `.tr()` never touches disk. With no translation
// found, easy_localization falls back to returning the key itself, so this
// test verifies PopUp's logic rather than your translation file contents.
class _FakeAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {};
  }
}

void main() {
  setUpAll(() async {
    // See batch_card_test.dart for why both of these are needed together:
    // EasyLocalization reads the saved locale via shared_preferences, which
    // has no real platform channel implementation under flutter test.
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Widget buildTestable(Widget child) {
    return EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      assetLoader: _FakeAssetLoader(),
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  // The message is built as three TextSpans inside one RichText, not
  // separate Text widgets, so we can't use find.text() the way we did for
  // BatchCard. This pulls the whole span tree out and flattens it to plain
  // text for comparison.
  String plainMessageText(WidgetTester tester) {
    final richText = tester.widget<RichText>(find.byType(RichText));
    return (richText.text as TextSpan).toPlainText();
  }

  group('PopUp', () {
    testWidgets(
        'renders messagebefore, bold batchName, and messageAfter combined',
        (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const PopUp(
            icon: Icon(Icons.warning),
            messagebefore: 'Are you sure you want to delete',
            batchName: 'Coop A',
            messageAfter: '?',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Exact spacing matches the widget's current string interpolation
      // (" " after messagebefore, " " before messageAfter). If that
      // formatting changes, update this expectation to match.
      expect(
        plainMessageText(tester),
        'Are you sure you want to delete Coop A ?',
      );

      final richText = tester.widget<RichText>(find.byType(RichText));
      final spans = (richText.text as TextSpan).children!.cast<TextSpan>();
      final batchSpan = spans.firstWhere((s) => s.text == 'Coop A');
      expect(batchSpan.style?.fontWeight, FontWeight.bold);

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('does not throw when message fields are omitted (defaults)',
        (tester) async {
      await tester.pumpWidget(
        buildTestable(const PopUp(icon: Icon(Icons.info))),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders no buttons when neither button text is provided',
        (tester) async {
      await tester.pumpWidget(
        buildTestable(const PopUp(icon: Icon(Icons.info))),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets(
        'renders a single, untranslated button when only mainButtonText is '
        'given, and fires onMainAction on tap',
        (tester) async {
      // "Confirm" is asserted as raw text on purpose: the single-button
      // branch in _buildButtons renders `mainButtonText!` directly, without
      // .tr(), unlike the two-button branch. This test documents that
      // asymmetry rather than assuming it's a translation key.
      var mainTapped = 0;

      await tester.pumpWidget(
        buildTestable(
          PopUp(
            icon: const Icon(Icons.info),
            mainButtonText: 'Confirm',
            onMainAction: () => mainTapped++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(mainTapped, 1);
    });

    testWidgets(
        'throws when only secondaryButtonText is given without '
        'mainButtonText (documents a real bug in _buildButtons)',
        (tester) async {
      // _buildButtons is invoked whenever EITHER button text is non-null,
      // but its non-two-button fallback branch unconditionally does
      // `mainButtonText!`. With mainButtonText null, that null-check
      // operator throws. This test pins down the current (broken) behavior
      // so it's visible in the suite rather than failing silently in
      // production.
      await tester.pumpWidget(
        buildTestable(
          const PopUp(
            icon: Icon(Icons.info),
            secondaryButtonText: 'Cancel',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isA<TypeError>());
    });

    testWidgets(
        'renders two translated buttons when both texts are given, each '
        'firing its own callback independently',
        (tester) async {
      var mainTapped = 0;
      var secondaryTapped = 0;

      await tester.pumpWidget(
        buildTestable(
          PopUp(
            icon: const Icon(Icons.warning),
            mainButtonText: 'Delete',
            secondaryButtonText: 'Cancel',
            onMainAction: () => mainTapped++,
            // Supplying this explicitly avoids exercising the widget's
            // default context.pop(context) fallback, which would need a
            // real GoRouter ancestor to run without throwing — out of
            // scope for this widget test.
            onsecondaryAction: () => secondaryTapped++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(OutlinedButton, 'Delete'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(secondaryTapped, 1);
      expect(mainTapped, 0);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(mainTapped, 1);
      expect(secondaryTapped, 1);
    });
  });
}
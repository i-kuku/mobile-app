import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:ikuku/features/batches/presentation/Widgets/pop_up.dart';

class FakeAssetLoader extends AssetLoader {
  const FakeAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return <String , dynamic>{
      'Are you sure you want to delete': 'Are you sure you want to delete',
      'batchAlpha': 'batchAlpha',
      'permanently': 'permanently',
      'Show Dialog': 'Show Dialog',
      'Delete': 'Delete',
      'cancel': 'cancel',
      'confirm': 'confirm',
      'Confirm': 'Confirm',
      'Cancel': 'Cancel',
      'OK': 'OK',
    };
  }
  @override
  String? getLocaleString(Map<String, dynamic> data, String key) {
    return key;
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock SharedPreferences channel before EasyLocalization initialization
    SharedPreferences.setMockInitialValues({});
    
    await EasyLocalization.ensureInitialized();
  });

  Widget buildTestablePopUp({
    required Widget popup,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => popup,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      ],
    );

    return EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translation',
      fallbackLocale: const Locale('en'),
      assetLoader: const FakeAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            routerConfig: router,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
          );
        },
      ),
    );
  }

  group('popUp Widget Tests', () {
    testWidgets('renders icon, message texts and batch name correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestablePopUp(
          popup: const PopUp(
            icon: Icon(Icons.warning, key: Key('popup_icon')),
            messagebefore: 'Are you sure you want to delete',
            batchName: 'batchAlpha',
            messageAfter: 'permanently',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('popup_icon')), findsOneWidget);
      expect(
          find.textContaining('Are you sure you want to delete'), findsOneWidget);
      expect(find.textContaining('batchAlpha'), findsOneWidget);
      expect(find.textContaining('permanently'), findsOneWidget);
    });

    testWidgets(
        'renders two side by side buttons when both main and secondary texts are provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestablePopUp(
          popup: const PopUp(
            icon: Icon(Icons.info),
            mainButtonText: 'Delete',
            secondaryButtonText: 'cancel',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(OutlinedButton, 'Delete'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'cancel'), findsOneWidget);
    });

    testWidgets('triggers main action callback on tap',
        (WidgetTester tester) async {
      bool mainActionTriggered = false;

      await tester.pumpWidget(
        buildTestablePopUp(
          popup: PopUp(
            icon: const Icon(Icons.info),
            mainButtonText: 'confirm',
            secondaryButtonText: 'cancel',
            onMainAction: () => mainActionTriggered = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'confirm'));
      await tester.pump();

      expect(mainActionTriggered, isTrue);
    });

    testWidgets(
        'dismisses dialog via context.pop when secondary action is tapped without a custom callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestablePopUp(
          popup: const PopUp(
            icon: Icon(Icons.info),
            mainButtonText: 'Confirm',
            secondaryButtonText: 'Cancel',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.byType(PopUp), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(PopUp), findsNothing);
    });

    testWidgets(
        'renders full-width single ElevatedButton when only mainButtonText is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestablePopUp(
          popup: const PopUp(
            icon: Icon(Icons.check),
            mainButtonText: 'OK',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'OK'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });
}
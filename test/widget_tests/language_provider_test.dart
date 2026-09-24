import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/settings/languages/model/language.dart';
import 'package:ikuku/features/settings/languages/presentation/components/language_option_widget.dart';
import 'package:ikuku/features/settings/languages/provider/language_provider.dart';
import 'package:ikuku/routing/app_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MapAssetLoader extends AssetLoader {
  const _MapAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      switch (locale.languageCode) {
        'sw' => {
          'greeting': 'Habari',
          'english': 'Kiingereza',
          'swahili': 'Kiswahili',
        },
        _ => {'greeting': 'Hello', 'english': 'English', 'swahili': 'Swahili'},
      };
}

void main() {
  late LanguageProvider provider;
  final providerHolder = ValueNotifier<LanguageProvider?>(null);

  setUp(() => providerHolder.value = null);

  /// Mounts EasyLocalization around a MaterialApp that owns the app's
  /// [navigatorKey] (LanguageProvider reads its context on creation),
  /// then creates the provider and waits for its initial load.
  Future<void> pumpApp(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
    Locale startLocale = const Locale('en'),
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    await tester.runAsync(EasyLocalization.ensureInitialized);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('sw')],
        path: 'unused',
        assetLoader: const _MapAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: startLocale,
        saveLocale: false,
        child: Builder(
          builder: (context) => MaterialApp(
            navigatorKey: navigatorKey,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: Scaffold(
              body: ValueListenableBuilder<LanguageProvider?>(
                valueListenable: providerHolder,
                builder: (context, provider, _) => Column(
                  children: [
                    Text('greeting'.tr()),
                    if (provider != null)
                      ChangeNotifierProvider.value(
                        value: provider,
                        child: Column(
                          children: [
                            for (final language in languages)
                              LanguageOptionWidget(language: language),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    // The navigator now exists, so the provider can be created; then show
    // the language options that depend on it.
    provider = (await tester.runAsync(() async {
      final p = LanguageProvider();
      await p.loadLanguage();
      return p;
    }))!;
    providerHolder.value = provider;
    await tester.pumpAndSettle();
  }

  Locale currentLocale(WidgetTester tester) =>
      EasyLocalization.of(tester.element(find.byType(Scaffold)))!.locale;

  testWidgets('can be created and used before any navigator exists', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SizedBox());
    expect(navigatorKey.currentContext, isNull);

    await tester.runAsync(() async {
      final provider = LanguageProvider();
      await provider.loadLanguage();
      await provider.setLanguage('sw');
      expect(provider.selectedLanguage, 'sw');
    });
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_language'), 'sw');
  });

  testWidgets('defaults to English and saves that choice', (tester) async {
    await pumpApp(tester);

    expect(provider.selectedLanguage, 'en');
    expect(provider.isLoading, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_language'), 'en');
    expect(currentLocale(tester), const Locale('en'));
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('restores a saved language', (tester) async {
    await pumpApp(
      tester,
      prefs: {'app_language': 'sw'},
      startLocale: const Locale('sw'),
    );

    expect(provider.selectedLanguage, 'sw');
    expect(find.text('Habari'), findsOneWidget);
  });

  testWidgets('setLanguage saves, switches locale and notifies', (
    tester,
  ) async {
    await pumpApp(tester);
    final loadingStates = <bool>[];
    provider.addListener(() => loadingStates.add(provider.isLoading));

    await tester.runAsync(() => provider.setLanguage('sw'));
    await tester.pumpAndSettle();

    expect(provider.selectedLanguage, 'sw');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_language'), 'sw');
    expect(currentLocale(tester), const Locale('sw'));
    expect(find.text('Habari'), findsOneWidget);
    expect(loadingStates, [true, false]);
  });

  testWidgets('tapping a language option selects it', (tester) async {
    await pumpApp(tester);
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(LanguageOptionWidget, 'English'),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );

    await tester.runAsync(() async {
      await tester.tap(find.text('Swahili'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(provider.selectedLanguage, 'sw');
    expect(
      find.descendant(
        of: find.widgetWithText(LanguageOptionWidget, 'Kiswahili'),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
  });
}

import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:ikuku/features/home/provider/analytics_provider.dart';
import 'package:ikuku/features/home/provider/tutorial_provider.dart';
import 'package:ikuku/features/settings/languages/provider/language_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routing/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'shared/services/supabase_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize SharedPreferences early to check language preference
  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('app_language');

  await Hive.initFlutter();
  await Hive.openBox<String>('offline_reports');
  await Hive.openBox<String>('sync_status');
  await Supabase.initialize(
    url: 'https://vrhujilkhtedvkhybtdx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZyaHVqaWxraHRlZHZraHlidGR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4MDY2ODEsImV4cCI6MjA2NzM4MjY4MX0.NLxRGmM4F6ckDcvbGW6SFvLKEd9Dn-8bieInZO6aPYs',
  );

  // Fix database constraints on app startup
  try {
    await SupabaseService().fixDatabaseConstraints();
  } catch (e) {
    debugPrint('Failed to fix database constraints: $e');
  }

  // Initialize offline services
  try {
    // await OfflineService.instance.initialize();
    // await OfflineDataService.instance.initialize();
    // await ConnectivityManager.instance.initialize();
  } catch (e) {
    debugPrint('Failed to initialize offline services: $e');
  }

  final startLocale = Locale(savedLanguage ?? 'en');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => BatchProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (context) => TutorialProvider()),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('sw')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: startLocale,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: appTheme,
      routerConfig: AppRouter.router,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
    );
  }
}

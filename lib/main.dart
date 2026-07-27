import 'package:flutter/material.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/features/auth/provider/auth_provider.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
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
  url:'https://ubzmplzgomzpczaspuyu.supabase.co' ,
  anonKey:'sb_publishable_DuH_Ckn1wyGVRa9l-BN9gw_DCoSqQYC',
  );
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
        ChangeNotifierProvider(create: (context) => InventoryProvider()),
        ChangeNotifierProvider(create: (context) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (context) => TutorialProvider()),
        ChangeNotifierProvider(create: (context) => FarmReportProvider()),

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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikuku/di/controllers.dart';
import 'package:ikuku/features/feature_create_farm/presentation/create_farm_page.dart';
import 'package:ikuku/features/feature_dashboard/presentation/farmer_dashboard.dart';
import 'package:ikuku/features/feature_onboarding/presentation/screens/welcome_screen.dart';
import 'package:ikuku/features/feature_sign_up/presentation/screens/farmer_registration_screen.dart';
import 'package:ikuku/features/feature_sign_up/presentation/screens/verification_screen.dart';
import 'package:ikuku/theme/my_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  invokeControllers();

  runApp(EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('sw')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      saveLocale: true,
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: FarmerDashboard(),
      theme: MyTheme.lightTheme,
      darkTheme: MyTheme.lightTheme,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikuku/features/feature_onboarding/presentation/screens/welcome_screen.dart';
import 'package:ikuku/theme/my_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
      theme: MyTheme.lightTheme,
      darkTheme: MyTheme.lightTheme,
    );
  }
}

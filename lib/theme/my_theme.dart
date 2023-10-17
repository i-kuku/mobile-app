import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

class MyTheme {
  /// Light Theme
  static ThemeData get lightTheme {
    /// Overriding Material Theme
    MaterialColor mycolor = const MaterialColor(
      0xFF00681D,
      <int, Color>{
        50: primary,
        100: primary,
        200: primary,
        300: primary,
        400: primary,
        500: primary,
        600: primary,
        700: primary,
        800: primary,
        900: primary,
      },
    );

    return ThemeData(
        primaryColor: primary,
        primaryColorLight: primaryAlt,
        primarySwatch: mycolor,
        scaffoldBackgroundColor: white,
        fontFamily: 'DMSans',
        textTheme: const TextTheme(
          bodySmall: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: textBlack500),
          bodyMedium: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: textBlack500),
          bodyLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: textBlack700),
          titleSmall: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: textBlack700),
          titleMedium: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: textBlack900),
          titleLarge: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: textBlack900),
        ));
  }
}

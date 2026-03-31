import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomColors {
  static const Color background = Colors.white;
  static const Color primary = Color(0xFF00681D);
  static const Color secondary = Color(0xFFF9B420);
  static const Color lightGreen = Color(0xFFAAC641);
  static const Color lightYellow = Color(0xFFFEF8E2);
  static const Color text = Color(0xFF243B25);
  static const Color textDisabled = Color(0xFFABABAB);
  static const Color successColor = Color(0xFF00A152); // Green for success
  static const Color errorColor = Color(0xFFE53935); // Red for error
  static const Color textColorSecondary = Color(0xFF666666); // Secondary text

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF98B130), Color(0xFFF7C02D), Color(0xFFF9B420)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

final ThemeData appTheme = ThemeData(
  textTheme: GoogleFonts.dmSansTextTheme().copyWith(
    bodyLarge: GoogleFonts.dmSans(color: CustomColors.text),
    bodyMedium: GoogleFonts.dmSans(color: CustomColors.text),
    bodySmall: GoogleFonts.dmSans(color: CustomColors.textDisabled),
    titleLarge: GoogleFonts.dmSans(
      color: CustomColors.text,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.dmSans(color: CustomColors.text),
    titleSmall: GoogleFonts.dmSans(color: CustomColors.textDisabled),
  ),
  scaffoldBackgroundColor: CustomColors.background,
  primaryColor: CustomColors.primary,
  colorScheme: ColorScheme.fromSeed(
    seedColor: CustomColors.primary,
    primary: CustomColors.primary,
    secondary: CustomColors.secondary,
    background: CustomColors.background,
    onPrimary: CustomColors.background,
    onSecondary: CustomColors.text,
    onBackground: CustomColors.text,
    surface: CustomColors.lightYellow,
    onSurface: CustomColors.text,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: CustomColors.background,
    foregroundColor: CustomColors.primary,
    elevation: 0,
    iconTheme: IconThemeData(color: CustomColors.primary),
    titleTextStyle: TextStyle(
      color: CustomColors.primary,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      foregroundColor: WidgetStateProperty.all(CustomColors.text),
      backgroundColor: WidgetStateProperty.all(
        Colors.transparent,
      ), // Use gradient
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(
        CustomColors.lightGreen.withOpacity(0.1),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: CustomColors.primary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: CustomColors.primary.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: CustomColors.primary, width: 2),
    ),
    hintStyle: TextStyle(color: CustomColors.textDisabled),
    labelStyle: TextStyle(color: CustomColors.text),
  ),
);

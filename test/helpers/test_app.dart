import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikuku/theme/app_theme.dart';

/// Load DM Sans from the bundled assets instead of hitting the network.
void disableFontFetching() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

/// Wraps [child] in a Scaffold inside a MaterialApp using the app theme.
Widget wrap(Widget child) {
  disableFontFetching();
  return MaterialApp(theme: appTheme, home: Scaffold(body: child));
}

/// Wraps [child] in a GoRouter-backed MaterialApp, for widgets that call
/// `context.pop()` / `context.go()`.
Widget wrapWithRouter(Widget child) {
  disableFontFetching();
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => Scaffold(body: child)),
    ],
  );
  return MaterialApp.router(theme: appTheme, routerConfig: router);
}

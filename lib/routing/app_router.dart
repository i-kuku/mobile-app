import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/onboarding/create_farm_page.dart';
import 'package:ikuku/features/onboarding/onboarding_page.dart';
import 'package:ikuku/features/onboarding/recovery_setup_page.dart';
import 'package:ikuku/features/settings/languages/presentation/language_selection_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/splash/splash_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static Future<bool> onboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/splash',
    navigatorKey:navigatorKey,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            OnboardingPage(onFinish: () => context.go('/sign-in')),
      ),
      // GoRoute(
      //   path: '/sign-in',
      //   builder: (context, state) => const SignInPage(),
      // ),
      // GoRoute(
      //   path: '/reset-password',
      //   builder: (context, state) => const ResetPasswordPage(),
      // ),
      GoRoute(
        path: '/language',
        builder: (context, state) => LanguageSelectionPage(
          onContinue: () async {
            final fromProfile = (state.extra as Map?)?['fromProfile'] == true;
            if (fromProfile) {
              context.go('/profile');
            } else {
              // Check onboarding status for robustness
              final prefs = await SharedPreferences.getInstance();
              final onboardingComplete =
                  prefs.getBool('onboarding_complete') ?? false;
              if (onboardingComplete && context.mounted) {
                context.go('/sign-in');
              } else {
                if (context.mounted) {
                  context.go('/onboarding');
                }
              }
            }
          },
        ),
      ),
      // GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
      // GoRoute(
      //   path: '/batches',
      //   builder: (context, state) {
      //     final fromReportsPage =
      //         (state.extra as Map?)?['fromReportsPage'] == true;
      //     return BatchesPage(fromReportsPage: fromReportsPage);
      //   },
      // ),
      // GoRoute(
      //   path: '/inventory-categories',
      //   builder: (context, state) => const CategorySelectionPage(),
      // ),
      // GoRoute(
      //   path: '/inventory',
      //   builder: (context, state) => const CategorySelectionPage(),
      // ),
      // GoRoute(
      //   path: '/inventory-items/:category',
      //   builder: (context, state) {
      //     final category = state.pathParameters['category'] ?? 'feed';
      //     return InventoryPage(category: category);
      //   },
      // ),
      // GoRoute(
      //   path: '/records',
      //   builder: (context, state) => const RecordsPage(),
      // ),
      // GoRoute(
      //   path: '/reports',
      //   builder: (context, state) => const ReportsPage(),
      // ),
      // GoRoute(
      //   path: '/farm-summary',
      //   builder: (context, state) => const FarmSummaryPage(),
      // ),
      // GoRoute(
      //   path: '/report-entry',
      //   builder: (context, state) => const FarmReportEntryPage(),
      // ),
      // GoRoute(
      //   path: '/all-reports',
      //   builder: (context, state) => const AllReportsPage(),
      // ),
      // GoRoute(
      //   path: '/offline-test',
      //   builder: (context, state) => const OfflineTestPage(),
      // ),
      // GoRoute(
      //   path: '/profile',
      //   builder: (context, state) => const ProfilePage(),
      // ),
      GoRoute(
        path: '/create-farm',
        builder: (context, state) => CreateFarmPage(
          name: (state.extra as Map?)?['name'] ?? '',
          phone: (state.extra as Map?)?['phone'] ?? '',
        ),
      ),
      GoRoute(
        path: '/recovery-setup',
        builder: (context, state) => const RecoverySetupPage(),
      ),
    ],
    redirect: (context, state) async {
      final user = Supabase.instance.client.auth.currentUser;
      final loggingIn = state.matchedLocation == '/sign-in';
      final resettingPassword = state.matchedLocation == '/reset-password';
      final onboarding = state.matchedLocation == '/onboarding';
      final language = state.matchedLocation == '/language';
      final splash = state.matchedLocation == '/splash';
      final prefs = await SharedPreferences.getInstance();
      final langSet = prefs.getString('app_language') != null;
      final onboardingComplete = await AppRouter.onboardingComplete();

      // If on splash screen, let it handle its own navigation
      if (splash) return null;

      if (!langSet && !language) return '/language';
      if (!onboardingComplete && !onboarding && langSet) return '/onboarding';
      if (user == null &&
          !loggingIn &&
          !resettingPassword &&
          langSet &&
          onboardingComplete) {
        return '/sign-in';
      }
      if (user != null && loggingIn) return '/';
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('404 - Page Not Found')),
    ),
  );
}

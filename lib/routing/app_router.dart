import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/Inventory/presentation/screens/feeds_page.dart';
import 'package:ikuku/features/Inventory/presentation/screens/inventory_hub_page.dart';
import 'package:ikuku/features/Inventory/presentation/screens/items_page.dart';
import 'package:ikuku/features/Inventory/presentation/screens/medicines_page.dart';
import 'package:ikuku/features/batches/presentation/screens/confirm_batch_page.dart';
import 'package:ikuku/features/batches/presentation/screens/create_batch_page.dart';
import 'package:ikuku/features/batches/presentation/screens/edit_batch_page.dart';
import 'package:ikuku/features/batches/presentation/screens/manage_batch_page.dart';
import 'package:ikuku/features/auth/presentation/screens/auth_page.dart';
import 'package:ikuku/features/dashboard/presentation/pages/dashboard.dart';
import 'package:ikuku/features/home/presentation/home_page.dart';
import 'package:ikuku/features/onboarding/create_farm_page.dart';
import 'package:ikuku/features/onboarding/onboarding_page.dart';
import 'package:ikuku/features/onboarding/recovery_setup_page.dart';
import 'package:ikuku/features/profile/presentation/pages/profile_page.dart';
import 'package:ikuku/features/settings/languages/presentation/language_selection_page.dart';
import 'package:ikuku/features/smart_tips/presentation/screens/tip_detail_page.dart';
// import 'package:ikuku/features/shop/presentation/pages/my_shop_page.dart';
import 'package:ikuku/features/smart_tips/presentation/screens/tips_hub.dart';
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
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            // OnboardingPage(onFinish: () => context.go('/batches')),
            OnboardingPage(onFinish: () => context.go('/auth')),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
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
              final user = Supabase.instance.client.auth.currentUser;
              if (onboardingComplete && context.mounted) {
                context.go(user != null ? '/batches' : '/auth');
              } else {
                if (context.mounted) {
                  context.go('/onboarding');
                }
              }
            }
          },
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Dashboard(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) =>
                    const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-shop',
                builder: (context, state) => const TipsHub(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      // GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
      GoRoute(
        path: '/batches',
        builder: (context, state) => const ManageBatchPage(),
      ),
      GoRoute(
        path: '/create_batch_page',
        builder: (context, state) => const CreateBatchPage(),
      ),
      GoRoute(
        path: '/confirm_batch_page',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ConfirmBatchPage(batchData: data);
        },
      ),
      GoRoute(
        path: '/edit_batch_page',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return EditBatchPage(batchData: data);
        },
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => InventoryHubPage(),
        routes: [
          GoRoute(
            path: 'feedspage',
            builder: (context, state) => const FeedsPage(),
          ),
          GoRoute(
            path: 'medicines',
            builder: (context, state) => const MedicinesPage(),
          ),
          GoRoute(
            path: 'others',
            builder: (context, state) => const ItemsPage(),
          ),
        ],
      ),
      GoRoute(
  path: '/smart-tips',
  builder: (context, state) => const TipsHub(),
  routes: [
    GoRoute(
      path: 'tip_detail', 
      builder: (context, state) {
        final rawData = state.extra;
        final selectedBlogData = rawData is Map<String, String> ? rawData : <String, String>{};
        return TipDetailPage(blogDataMap: selectedBlogData);
      },
    ),
  ],
),
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
      final loggingIn = state.matchedLocation == '/auth';
      final onboarding = state.matchedLocation == '/onboarding';
      final language = state.matchedLocation == '/language';
      final splash = state.matchedLocation == '/splash';
      final root = state.matchedLocation == '/';
      final prefs = await SharedPreferences.getInstance();
      final langSet = prefs.getString('app_language') != null;
      final onboardingComplete = await AppRouter.onboardingComplete();

      // If on splash screen, let it handle its own navigation
      if (splash) return null;

      if (!langSet && !language) return '/language';
      if (!onboardingComplete && !onboarding && langSet) return '/onboarding';
      if (user == null) {
        if (!loggingIn && onboardingComplete) {
          return '/auth';
        }
      } 
       else {
         if (loggingIn || root) {
          //  return '/tips-hub';
           return '/';
       }
       }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('404 - Page Not Found')),
    ),
  );
}

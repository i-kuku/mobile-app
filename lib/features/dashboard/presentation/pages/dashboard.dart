import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/dashboard/presentation/components/app_bottom_nav_bar.dart';

class Dashboard extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const Dashboard({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, d) {
        if (didPop) return;
        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0, initialLocation: false);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: navigationShell,
          ),
        ),
        bottomNavigationBar: AppBottomNavbar(
          currentIndex: navigationShell.currentIndex,
          onTap: (int index) {
            final isSelected = navigationShell.currentIndex == index;
            if (!isSelected) {
              navigationShell.goBranch(index, initialLocation: false);
            }
          },
        ),
      ),
    );
  }
}

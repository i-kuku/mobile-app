import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          // Home: Go to dashboard
          context.go('/');
        } else if (index == 2) {
          // Profile: Go to profile page
          context.go('/profile');
        } else if (index == 1) {
          // My Shop: Show coming soon message (inactive)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('coming_soon'.tr()),
              duration: Duration(seconds: 2),
              backgroundColor: CustomColors.primary,
            ),
          );
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: currentIndex == 0 ? CustomColors.primary : Colors.grey,
          ),
          label: 'home'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store, color: Colors.grey),
          label: 'my_shop'.tr(),
          backgroundColor: Colors.grey.withOpacity(0.1),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: currentIndex == 2 ? CustomColors.primary : Colors.grey,
          ),
          label: 'profile'.tr(),
        ),
      ],
      selectedItemColor: CustomColors.primary,
      unselectedItemColor: Colors.grey,
    );
  }
}

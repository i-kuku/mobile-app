import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

class BottomNavBar extends StatelessWidget {
  final int? currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final highlighted = currentIndex != null;

    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex ?? 0,
      onTap: (index) {
        if (index == 0) {
          // Home: Go to dashboard
          context.go('/');
        } else if (index == 1) {
          // Profile: Go to profile page
          context.go('/my_shop');
        } else if (index == 2) {
          context.go('/profile');
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
          icon: Icon(
            Icons.store,
            color: currentIndex == 1 ? CustomColors.primary : Colors.grey,
          ),
          label: 'my_shop'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: currentIndex == 2 ? CustomColors.primary : Colors.grey,
          ),
          label: 'profile'.tr(),
        ),
      ],
      selectedItemColor: highlighted ? CustomColors.primary : Colors.grey,
      unselectedItemColor: Colors.grey,
    );
  }
}

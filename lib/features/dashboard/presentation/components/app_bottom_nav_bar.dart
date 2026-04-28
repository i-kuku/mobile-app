import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

class AppBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      elevation: 2.0,
      selectedItemColor: CustomColors.primary,
      unselectedItemColor: CustomColors.textDisabled,
      backgroundColor: CustomColors.background,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "home".tr()),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: "my_shop".tr()),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "profile".tr(),
        ),
      ],
    );
  }
}

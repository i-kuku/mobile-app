import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

class AppBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

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
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "My Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ]);
  }
}


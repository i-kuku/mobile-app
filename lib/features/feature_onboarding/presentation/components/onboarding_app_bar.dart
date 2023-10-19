import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

PreferredSizeWidget onboardingAppBar(
        {bool showBackButton = true, required VoidCallback onClick}) =>
    AppBar(
      title: SvgPicture.asset('assets/images/i-kuku-logo.svg',
          width: 40, height: double.infinity, fit: BoxFit.contain),
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              onPressed: onClick,
              icon: Icon(Icons.arrow_back_rounded,
                  color: Theme.of(Get.context!).iconTheme.color))
          : null,
      elevation: 0,
      backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
    );

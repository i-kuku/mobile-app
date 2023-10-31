import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

PreferredSizeWidget onboardingAppBar(
        {bool showBackButton = true,
        required Color navigationBarColor,
        required VoidCallback onClick}) =>
    AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarColor: Theme.of(Get.context!).scaffoldBackgroundColor,
          systemNavigationBarColor: navigationBarColor,
          systemNavigationBarIconBrightness: Brightness.dark),
      title: SvgPicture.asset('assets/images/i-kuku-logo.svg',
          key: const Key('i-kuku-logo'),
          width: 50,
          height: 50,
          fit: BoxFit.contain),
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

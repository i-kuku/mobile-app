import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../theme/colors.dart';

PreferredSizeWidget createFarmAppbar(
        {bool showBackButton = true,
        required Color navigationBarColor,
        required VoidCallback onBackClicked,
        required VoidCallback onSkipClicked}) =>
    AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarColor: Theme.of(Get.context!).scaffoldBackgroundColor,
          systemNavigationBarColor: navigationBarColor,
          systemNavigationBarIconBrightness: Brightness.dark),
      title: Text("Back"),
      titleTextStyle: TextStyle(
          fontSize: Theme.of(Get.context!).textTheme.titleSmall!.fontSize!,
          fontWeight: Theme.of(Get.context!).textTheme.bodyLarge!.fontWeight!,
          color: textAccentDark),
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
              onPressed: onBackClicked,
              icon: Icon(Icons.arrow_back_rounded,
                  color: Theme.of(Get.context!).iconTheme.color))
          : null,
      elevation: 0,
      backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
      actions: [TextButton(onPressed: onSkipClicked, child: Text("Skip"))],
    );

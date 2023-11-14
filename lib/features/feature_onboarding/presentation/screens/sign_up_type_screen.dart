import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../core/utils/locale_constants.dart';
import '../../../../theme/colors.dart';
import '../components/onboarding_app_bar.dart';

class SignUpTypeScreen extends StatefulWidget {
  const SignUpTypeScreen({super.key});

  @override
  State<SignUpTypeScreen> createState() => _SignUpTypeScreenState();
}

class _SignUpTypeScreenState extends State<SignUpTypeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: onboardingAppBar(
          onBackClicked: () => Get.back(),
          navigationBarColor: const Color(0xffFFF8E6),
          showBackButton: true),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            //  welcome message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Help us be of use to you",
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleLarge!.fontSize!,
                        fontWeight:
                            Theme.of(context).textTheme.bodyLarge!.fontWeight!,
                        color: textAccentDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What brings you to i-kuku?',
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleSmall!.fontSize!,
                        fontWeight:
                            Theme.of(context).textTheme.bodyLarge!.fontWeight!,
                        color: textAccentDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
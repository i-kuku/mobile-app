import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikuku/core/utils/locale_constants.dart';

import '../../../../theme/colors.dart';
import '../components/onboarding_app_bar.dart';

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
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
            Text(
              tr(LocaleConstants.chooseLanguageTitle),
              style: TextStyle(
                  fontSize:
                  Theme.of(context).textTheme.titleLarge!.fontSize!,
                  fontWeight: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .fontWeight!,
                  color: textAccentDark),
            ),
            const SizedBox(height: 8),
            Text(
              tr(LocaleConstants.chooseLanguageMessage),
              style: TextStyle(
                  fontSize:
                  Theme.of(context).textTheme.titleSmall!.fontSize!,
                  fontWeight: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .fontWeight!,
                  color: textAccentDark),
            ),
            const SizedBox(height: 24),
            //  language toggle
          ],
        ),
      ),
    );
  }
}

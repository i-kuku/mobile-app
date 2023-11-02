import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikuku/core/presentation/components/action_button.dart';
import 'package:ikuku/core/utils/locale_constants.dart';
import 'package:ikuku/features/feature_onboarding/presentation/components/language_toggle_item.dart';
import 'package:ikuku/features/feature_onboarding/presentation/controller/onboarding_controller.dart';

import '../../../../theme/colors.dart';
import '../components/onboarding_app_bar.dart';

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  final languages = ['English', 'Kiswahili'];
  late final OnboardingController _onboardingController;

  @override
  void initState() {
    super.initState();

    _onboardingController = Get.find<OnboardingController>();
  }

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
                    tr(LocaleConstants.chooseLanguageTitle),
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleLarge!.fontSize!,
                        fontWeight:
                            Theme.of(context).textTheme.bodyLarge!.fontWeight!,
                        color: textAccentDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(LocaleConstants.chooseLanguageMessage),
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleSmall!.fontSize!,
                        fontWeight:
                            Theme.of(context).textTheme.bodyLarge!.fontWeight!,
                        color: textAccentDark),
                  ),
                  const SizedBox(height: 24),
                  //  language toggle
                  ListView.separated(
                      itemBuilder: (context, index) => Obx(
                            () => LanguageToggleItem(
                                title: languages[index],
                                groupValue:
                                    _onboardingController.activeLanguage.value,
                                isActive: _onboardingController
                                        .activeLanguage.value ==
                                    languages[index],
                                onTap: () {
                                  _onboardingController.setActiveLanguage(
                                      languageTitle: languages[index]);
                                },
                                onChanged: (value) {
                                  _onboardingController.setActiveLanguage(
                                      languageTitle: languages[index]);
                                }),
                          ),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemCount: languages.length,
                      shrinkWrap: true)
                ],
              ),
            ),

            //  continue button
            Expanded(
                child: Column(
              children: [
                ActionButton(
                    text: tr(LocaleConstants.continueTitle), onTap: () {}),
                const SizedBox(height: 24),
                Text(
                  tr(LocaleConstants.chooseLanguagePreferencesMessage),
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.bodyLarge!.fontSize!,
                      fontWeight:
                          Theme.of(context).textTheme.bodyLarge!.fontWeight!,
                      color: textAccentLighter),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}

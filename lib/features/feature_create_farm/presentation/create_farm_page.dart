import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../theme/colors.dart';
import '../../feature_onboarding/presentation/components/onboarding_app_bar.dart';

class CreateFarmPage extends StatefulWidget {
  const CreateFarmPage({super.key});

  @override
  State<CreateFarmPage> createState() => _CreateFarmPageState();
}

class _CreateFarmPageState extends State<CreateFarmPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: onboardingAppBar(
          onBackClicked: () => Get.back(),
          navigationBarColor: const Color(0xffFFF8E6),
          showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //  create farm logo
            Text(
              "Create farm:",
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleLarge!.fontSize!,
                  fontWeight:
                      Theme.of(context).textTheme.bodyLarge!.fontWeight!,
                  color: textAccentDark),
            ),
          ],
        ),
      ),
    );
  }
}

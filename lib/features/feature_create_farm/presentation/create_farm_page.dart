import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ikuku/features/feature_create_farm/presentation/components/create_farm_appbar.dart';

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
      appBar: createFarmAppbar(
          onBackClicked: () => Get.back(),
          navigationBarColor: const Color(0xffFFF8E6),
          showBackButton: true),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              const SizedBox(height: 16),

              //  image
              SvgPicture.asset('assets/images/create_farm_logo.svg')
            ],
          ),
        ),
      ),
    );
  }
}

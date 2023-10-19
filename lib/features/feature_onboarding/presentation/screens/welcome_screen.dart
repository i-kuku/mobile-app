import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ikuku/core/presentation/components/action_button.dart';
import 'package:ikuku/features/feature_onboarding/presentation/components/onboarding_app_bar.dart';
import 'package:ikuku/theme/colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: onboardingAppBar(onClick: () {}, showBackButton: false),
      body: SafeArea(
        child: Stack(
          children: [
            //  orange circle
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: ClipPath(
                clipper: OvalTopBorderClipper(),
                child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.6,
                    color: Color(0xffFFF8E6)),
              ),
            ),
            //  content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  //  header
                  Expanded(
                      child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      "Bridging the Gap in Poultry\nManagement",
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleLarge!.fontSize!,
                          fontWeight: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .fontWeight!,
                          color: textAccentDark),
                    ),
                  )),
                  //  farmer image
                  Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/farmer.svg',
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.6,
                      ),
                      ActionButton(text: 'Get Started', onTap: () {}),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: 'Have an existing account? ',
                            style: Theme.of(context).textTheme.bodyMedium),
                        TextSpan(
                            text: 'LOGIN',
                            recognizer: TapGestureRecognizer()..onTap = () {},
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                              fontWeight: Theme.of(context).textTheme.bodyMedium!.fontWeight!,
                              color: textAccentLight,
                              decoration: TextDecoration.underline
                            )),
                      ]))
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

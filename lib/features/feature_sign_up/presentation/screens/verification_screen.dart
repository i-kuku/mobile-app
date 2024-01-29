import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/presentation/components/action_button.dart';
import '../../../../theme/colors.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_rounded,
                color: Theme.of(Get.context!).iconTheme.color)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).scaffoldBackgroundColor,
            statusBarIconBrightness: Brightness.dark),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //  image
              SvgPicture.asset('assets/images/verify_phone.svg'),

              const SizedBox(height: 24),

              //  title
              Text('Verify Phone Number',
                  style: Theme.of(context).textTheme.titleMedium),

              const SizedBox(height: 16),

              //  description
              Text(
                "A 4- digit code has been sent to \n+254721 XXX X89",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              //  pincode
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PinCodeTextField(
                    appContext: context,
                    length: 4,
                    obscureText: false,
                    pinTheme: PinTheme(
                        inactiveColor: Colors.black.withOpacity(0.3),
                        activeColor: Theme.of(context).primaryColor,
                        selectedColor: Theme.of(context).primaryColor)),
              ),

              const SizedBox(height: 32),

              //  sign up button
              ActionButton(text: 'VERIFY PHONE NUMBER', onTap: () {}),

              const SizedBox(height: 24),

              Text.rich(TextSpan(children: [
                TextSpan(
                    text: "Didn't get the code? ",
                    style: Theme.of(context).textTheme.bodyMedium),
                TextSpan(
                    text: 'Resend code',
                    recognizer: TapGestureRecognizer()..onTap = () {},
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize,
                        fontWeight:
                            Theme.of(context).textTheme.bodyMedium!.fontWeight!,
                        color: textAccentLight,
                        decoration: TextDecoration.underline)),
              ]))
            ],
          ),
        ),
      ),
    );
  }
}

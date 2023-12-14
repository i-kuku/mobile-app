import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ikuku/core/presentation/components/custom_text_field.dart';

import '../../../../theme/colors.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  const FarmerRegistrationScreen({super.key});

  @override
  State<FarmerRegistrationScreen> createState() =>
      _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).scaffoldBackgroundColor,
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //  logo and title
                          SvgPicture.asset('assets/images/i-kuku-logo.svg',
                              key: const Key('i-kuku-logo'),
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain),

                          //  title
                          Text("Register as farmer",
                              style: Theme.of(context).textTheme.titleLarge)
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    //  first name
                    CustomTextField(label: 'First name'),

                    const SizedBox(height: 16),

                    //  last name
                    CustomTextField(label: 'Last name'),

                    const SizedBox(height: 16),

                    //  phone number
                    CustomTextField(label: 'Phone number'),

                    const SizedBox(height: 24),

                    Text(
                      "I’m registering on behalf of a group",
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodyLarge!.fontSize!,
                          fontWeight: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .fontWeight!,
                          color: textAccentLighter),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

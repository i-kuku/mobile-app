import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ikuku/app_theme.dart';

enum StatusType { success, error }

class StatusFeedback extends StatelessWidget {
  final String heading;
  final String bodyText;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final StatusType statusType;
  final String imagePath;

  const StatusFeedback({
    Key? key,
    required this.heading,
    required this.bodyText,
    required this.buttonLabel,
    required this.onButtonPressed,
    required this.statusType,
    required this.imagePath,
  }) : super(key: key);

  Color get _buttonColor {
    return CustomColors.primary; // App green color for all buttons
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heading
            Text(
              heading,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: CustomColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),

            // Image
            Center(
              child: imagePath.endsWith('.svg')
                  ? SvgPicture.asset(imagePath, height: 200, width: 200)
                  : Image.asset(imagePath, height: 200, width: 200),
            ),
            const SizedBox(height: 32.0),

            // Body Text
            Text(
              bodyText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: CustomColors.textColorSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 2.0,
                ),
                child: Text(
                  buttonLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

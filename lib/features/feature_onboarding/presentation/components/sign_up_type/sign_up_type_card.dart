import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../theme/colors.dart';

class SignUpTypeCard extends StatelessWidget {
  final String assetImage;
  final String text;
  final VoidCallback? onTap;

  const SignUpTypeCard(
      {super.key,
      required this.assetImage,
      required this.text,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 48),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Theme.of(context).primaryColor, width: 2)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(assetImage, width: 48, height: 48),
            const SizedBox(height: 16),
            Text(
              text,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleSmall!.fontSize!,
                  fontWeight:
                      Theme.of(context).textTheme.bodyLarge!.fontWeight!,
                  color: textAccentDark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

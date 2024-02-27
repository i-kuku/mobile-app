import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ikuku/theme/colors.dart';

class QuickActionCard extends StatelessWidget {
  final String svg;
  final String title;
  final VoidCallback onTap;

  const QuickActionCard(
      {super.key, required this.svg, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 100,
        child: Column(
          children: [
            //  svg
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(shape: BoxShape.circle, color: secondary),
              child: Center(child: SvgPicture.asset(svg, width: 24, height: 24)),
            ),

            const SizedBox(height: 12),

            //  title
            Text(
              title,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                  fontWeight: Theme.of(context).textTheme.bodyLarge!.fontWeight,
                  color: textAccentDark),
            )
          ],
        ),
      ),
    );
  }
}

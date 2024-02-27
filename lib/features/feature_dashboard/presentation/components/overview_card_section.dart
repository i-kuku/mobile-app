import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ikuku/theme/colors.dart';

class OverviewCardSection extends StatelessWidget {
  final String title;
  final String titleSvg;
  final String description;

  const OverviewCardSection(
      {super.key,
      required this.title,
      required this.titleSvg,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(titleSvg, width: 24, height: 24),
              Text(
                title,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                    fontWeight:
                        Theme.of(context).textTheme.titleSmall!.fontWeight,
                    color: textAccentLight),
              )
            ],
          ),

          const SizedBox(height: 8),

          //  description
          Text(description,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                  fontWeight:
                      Theme.of(context).textTheme.titleMedium!.fontWeight,
                  color: textAccentDark))
        ],
      ),
    );
  }
}

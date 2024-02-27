import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';

class QuickActionSection extends StatefulWidget {
  const QuickActionSection({super.key});

  @override
  State<QuickActionSection> createState() => _QuickActionSectionState();
}

class _QuickActionSectionState extends State<QuickActionSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //  Title
        Text('Quick Actions',
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                fontWeight: Theme.of(context).textTheme.bodyMedium!.fontWeight,
                color: textAccentDark)),

        //  quick actions

      ],
    );
  }
}

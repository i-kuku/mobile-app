import 'package:flutter/material.dart';
import 'package:ikuku/features/feature_dashboard/presentation/components/quick_action_card.dart';

import '../../../../theme/colors.dart';

class QuickActionSection extends StatefulWidget {
  const QuickActionSection({super.key});

  @override
  State<QuickActionSection> createState() => _QuickActionSectionState();
}

class _QuickActionSectionState extends State<QuickActionSection> {
  late final List<Widget> quickActions = [
    QuickActionCard(
      svg: 'assets/images/icon_images/report.svg',
      title: 'Farm report',
      onTap: () {},
    ),
    QuickActionCard(
      svg: 'assets/images/icon_images/inventory.svg',
      title: 'Inventory',
      onTap: () {},
    ),
    QuickActionCard(
      svg: 'assets/images/icon_images/add.svg',
      title: 'Add Farm',
      onTap: () {},
    ),
    QuickActionCard(
      svg: 'assets/images/icon_images/student.svg',
      title: 'Learning',
      onTap: () {},
    ),
    QuickActionCard(
      svg: 'assets/images/icon_images/doctor.svg',
      title: 'E-extension',
      onTap: () {},
    ),
    QuickActionCard(
      svg: 'assets/images/icon_images/ecommerce.svg',
      title: 'Buy/Sell',
      onTap: () {},
    ),
  ];

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

        const SizedBox(height: 24),

        //  quick actions
        Expanded(
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 24),
              itemBuilder: (context, index) => quickActions[index],
              itemCount: quickActions.length),
        )
      ],
    );
  }
}

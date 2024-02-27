import 'package:flutter/material.dart';
import 'package:ikuku/features/feature_dashboard/presentation/components/overview_card_section.dart';

class FarmerDashboardOverviewCard extends StatefulWidget {
  const FarmerDashboardOverviewCard({super.key});

  @override
  State<FarmerDashboardOverviewCard> createState() =>
      _FarmerDashboardOverviewCardState();
}

class _FarmerDashboardOverviewCardState
    extends State<FarmerDashboardOverviewCard> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 1.2,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 8),
                  spreadRadius: 5,
                  blurRadius: 10)
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  title
            Text('Kuku Farm Inventory',
                style: Theme.of(context).textTheme.bodyLarge),

            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //  Birds
                OverviewCardSection(
                    title: 'Birds',
                    titleSvg: 'assets/images/icon_images/chicken.svg',
                    description: '0 Kgs'),
                //  Feeds
                OverviewCardSection(
                    title: 'Feeds',
                    titleSvg: 'assets/images/icon_images/feeds.svg',
                    description: '0 Kgs'),
                //  Eggs
                OverviewCardSection(
                    title: 'Eggs',
                    titleSvg: 'assets/images/icon_images/eggs.svg',
                    description: '0 Kgs'),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

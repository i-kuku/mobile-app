import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/home/presentation/widgets/analytic_card.dart';
import 'package:ikuku/features/home/provider/analytics_provider.dart';

import 'package:provider/provider.dart';

class Analytics extends StatelessWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider,child) {
        return Container(
          width: double.infinity,
          height: 117,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1400681D),
                blurRadius: 10,
                offset: Offset(2, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AnalyticsCard(
                name: "birds".tr(),
                icon: 'assets/icons/animal-chicken.svg',
               
                value: provider.summary.totalBirds.toString(),
              ),
              AnalyticsCard(
                name: "feeds".tr(),
                icon: 'assets/icons/feeds.svg',
                value: provider.summary.totalFeeds.toString(),
              ),
              AnalyticsCard(
                name: "eggs".tr(),
                icon:  'assets/icons/eggs-f.svg',
                value:
                    provider.summary.totalEggs.toString(),
              ),
            ],
          ),
        );
      },
    );
  }
}

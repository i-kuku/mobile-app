import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/home/provider/analytics_provider.dart';
import 'package:provider/provider.dart';

class SalutationWidget extends StatelessWidget {
  const SalutationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context,provider,child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'welcome_back'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                provider.summary.userName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

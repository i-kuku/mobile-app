import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SalutationWidget extends StatelessWidget {
  const SalutationWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
            // userName != null ? userName! : 'type_here'.tr(),
            'type_here'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

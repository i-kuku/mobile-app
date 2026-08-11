import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';

import 'package:ikuku/theme/app_theme.dart';

class ReportHeaderCard extends StatelessWidget {
  const ReportHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<FarmReportProvider>();
    final batch = report.batch;

    final formattedDate = DateFormat('dd MMM yyyy').format(report.reportDate);
    final batchLabel = batch != null
        ? '${batch.name} - ${batch.typeOfBird}'
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'farm_report'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: CustomColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(formattedDate, style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 20),
              const Icon(Icons.layers, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(batchLabel, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

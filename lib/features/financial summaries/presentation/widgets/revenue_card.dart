import 'package:flutter/material.dart';
import 'package:ikuku/features/financial%20summaries/model/financial_summary_model.dart';
import 'package:ikuku/theme/app_theme.dart';

class RevenueCard extends StatelessWidget {
  final FinancialSummaryModel summary;

  const RevenueCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final double netRevenue = summary.totalSales - summary.totalExpenses;
    final bool showPredicted = summary.totalSales <= 0;

    final double displayValue = showPredicted
        ? (summary.predictedRevenue ?? 0)
        : netRevenue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.savings_outlined,
                color: CustomColors.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                showPredicted ? 'Total Predicted Revenue' : 'Total Revenue',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ksh ${displayValue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Subtitle message
          const SizedBox(height: 8),
          Text(
            showPredicted
                ? 'If you sell all remaining chicken at Ksh 600 you are predicted to earn this money at the end of your cycle'
                : '',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
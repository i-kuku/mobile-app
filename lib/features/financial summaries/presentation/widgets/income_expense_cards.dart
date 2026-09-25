import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/financial%20summaries/model/financial_summary_model.dart';

class IncomeExpenseCards extends StatelessWidget {
  final FinancialSummaryModel summary;

  const IncomeExpenseCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text('total_income'.tr(), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ksh ${summary.totalIncome}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_downward, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text('total_expenses'.tr(), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ksh ${summary.totalExpenses}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
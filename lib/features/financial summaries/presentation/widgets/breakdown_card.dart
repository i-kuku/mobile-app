import 'package:flutter/material.dart';
import 'package:ikuku/features/financial%20summaries/model/financial_summary_model.dart';
import 'package:ikuku/theme/app_theme.dart';

class BreakdownCard extends StatefulWidget {
  final FinancialSummaryModel summary;

  const BreakdownCard({super.key, required this.summary});

  @override
  State<BreakdownCard> createState() => _BreakdownCardState();
}

class _BreakdownCardState extends State<BreakdownCard> {
  bool _showIncome = true;

  @override
  Widget build(BuildContext context) {
    final breakdown = _showIncome
        ? widget.summary.incomeBreakdownPercent
        : widget.summary.expenseBreakdownPercent;

    final amounts = _showIncome
        ? widget.summary.incomeBreakdownAmounts
        : widget.summary.expenseBreakdownAmounts;

    final double totalBase = _showIncome 
        ? widget.summary.totalSales 
        : widget.summary.totalExpenses;

    final Map<String, Color> colors = {
      'chicken': Colors.lightGreen,
      'eggs': Colors.orange,
      'manure': Colors.brown,
      'feeds': Colors.amber,
      'vaccines': Colors.grey.shade800,
      'others': Colors.blue,
      'other': Colors.blue,
      'birds': Colors.purple,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _toggleTab('Income', _showIncome, () => setState(() => _showIncome = true)),
              ),
              Expanded(
                child: _toggleTab('Expenses', !_showIncome, () => setState(() => _showIncome = false)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Categories List
          for (final entry in breakdown.entries) ...[
            Builder(
              builder: (context) {
                final String categoryKey = entry.key.toLowerCase();
                final double amount = amounts[entry.key] ?? amounts[categoryKey] ?? 0.0;
                
                // Dynamic fallback percentage calculation if backend return is 0
                double rawPercent = entry.value;
                if ((rawPercent == 0 || rawPercent.isNaN) && totalBase > 0) {
                  rawPercent = (amount / totalBase) * 100;
                }

                // Progress bar value must stay strictly between 0.0 and 1.0
                final double progressValue = totalBase > 0 
                    ? (amount / totalBase).clamp(0.0, 1.0) 
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key[0].toUpperCase() + entry.key.substring(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Ksh ${amount.toStringAsFixed(0)} (${rawPercent.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors[categoryKey] ?? CustomColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _toggleTab(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? CustomColors.primary : Colors.grey.shade600,
              ),
            ),
          ),
          Container(
            height: 3,
            color: active ? CustomColors.primary : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
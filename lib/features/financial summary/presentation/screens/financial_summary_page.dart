import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/financial%20summary/provider/financial_provider.dart';
import 'package:provider/provider.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';

import 'package:ikuku/theme/app_theme.dart';

class FinancialSummaryPage extends StatefulWidget {
  const FinancialSummaryPage({super.key});

  @override
  State<FinancialSummaryPage> createState() => _FinancialSummaryPageState();
}

class _FinancialSummaryPageState extends State<FinancialSummaryPage> {
  bool _showIncome = true; // toggle between Income / Expenses breakdown

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BatchProvider>().fetchBatches();
      context.read<FinancialSummaryProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final financialProvider = context.watch<FinancialSummaryProvider>();
    final batchProvider = context.watch<BatchProvider>();
    final summary = financialProvider.summary;

    return Scaffold(
      backgroundColor: const Color(0xfff7f9fa),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CustomColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Financial Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: CustomColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: financialProvider.isLoading || summary == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _filtersRow(context, financialProvider, batchProvider),
                const SizedBox(height: 16),
                _revenueCard(summary),
                const SizedBox(height: 16),
                _incomeExpenseCards(summary),
                const SizedBox(height: 16),
                _breakdownCard(summary),
                const SizedBox(height: 16),
                _storeInventoryCard(summary),
              ],
            ),
    );
  }

  Widget _filtersRow(
    BuildContext context,
    FinancialSummaryProvider provider,
    BatchProvider batchProvider,
  ) {
    return Row(
      children: [
        Expanded(
          child: _dropdownShell(
            child: DropdownButton<String?>(
              value: provider.selectedBatchId,
              isExpanded: true,
              underline: const SizedBox(),
              hint: const Text('All Batches'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Batches'),
                ),
                ...batchProvider.batches.map(
                  (batch) => DropdownMenuItem<String?>(
                    value: batch.id,
                    child: Text(batch.name),
                  ),
                ),
              ],
              onChanged: (value) => provider.setBatch(value),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _dropdownShell(
            child: DropdownButton<String>(
              value: provider.selectedTimeframe,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: '3 Months', child: Text('3 Months')),
                DropdownMenuItem(value: 'Life Cycle', child: Text('Life Cycle')),
              ],
              onChanged: (value) {
                if (value != null) provider.setTimeframe(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownShell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }

  Widget _revenueCard(summary) {
    final isPredicted = summary.predictedRevenue != null;
    final value = isPredicted ? summary.predictedRevenue : summary.totalRevenue;

    return _cardShell(
      color: const Color(0xFFFFF6DA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings_outlined, color: CustomColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                isPredicted ? 'Total Predicted Revenue' : 'Total Revenue',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ksh ${value ?? 0}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (isPredicted) ...[
            const SizedBox(height: 8),
            Text(
              'If you sell all remaining chicken at Ksh 600 you are predicted '
              'to earn this money at the end of your cycle',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _incomeExpenseCards(summary) {
    return Row(
      children: [
        Expanded(
          child: _cardShell(
            color: const Color(0xFFEAF7EC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text('Total Income', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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
          child: _cardShell(
            color: const Color(0xFFFFF3E0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_downward, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text('Total Expenses', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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

  Widget _breakdownCard(summary) {
    final breakdown = _showIncome
        ? summary.incomeBreakdownPercent
        : summary.expenseBreakdownPercent;

    final colors = {
      'chicken': Colors.green,
      'eggs': Colors.orange,
      'manure': Colors.brown,
      'feeds': Colors.orange,
      'vaccines': Colors.grey.shade800,
      'others': Colors.blue,
      'birds': Colors.purple,
    };

    return _cardShell(
      color: Colors.white,
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
          for (final entry in breakdown.entries)
            if (entry.value > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key[0].toUpperCase() + entry.key.substring(1),
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          '${entry.value.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors[entry.key] ?? CustomColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _toggleTab(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? CustomColors.primary : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              color: active ? CustomColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _storeInventoryCard(summary) {
    return _cardShell(
      color: const Color(0xFFEAF7EC),
      child: Row(
        children: [
          const Icon(Icons.home_outlined, color: CustomColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Cost Of Items In Store',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'Ksh ${summary.storeInventoryValue}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardShell({required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
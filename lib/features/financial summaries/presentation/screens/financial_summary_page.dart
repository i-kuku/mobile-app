import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/features/financial%20summaries/model/financial_summary_model.dart';
import 'package:ikuku/features/financial%20summaries/presentation/widgets/breakdown_card.dart';
import 'package:ikuku/features/financial%20summaries/presentation/widgets/financial_filters_row.dart';
import 'package:ikuku/features/financial%20summaries/presentation/widgets/income_expense_cards.dart';
import 'package:ikuku/features/financial%20summaries/presentation/widgets/revenue_card.dart';
import 'package:ikuku/features/financial%20summaries/presentation/widgets/store_inventory_card.dart';
import 'package:ikuku/features/financial%20summaries/provider/financial_provider.dart';
import 'package:ikuku/theme/app_theme.dart';

import 'package:provider/provider.dart';

class FinancialSummaryPage extends StatefulWidget {
  const FinancialSummaryPage({super.key});

  @override
  State<FinancialSummaryPage> createState() => _FinancialSummaryPageState();
}

class _FinancialSummaryPageState extends State<FinancialSummaryPage> {
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
    final FinancialSummaryModel? summary = financialProvider.summary;

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
      body: financialProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : summary == null
          ? const Center(
              child: Text(
                'No financial summary records found.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: financialProvider.load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FinancialFiltersRow(
                    provider: financialProvider,
                    batchProvider: batchProvider,
                  ),
                  const SizedBox(height: 16),
                  RevenueCard(summary: summary),
                  const SizedBox(height: 16),
                  IncomeExpenseCards(summary: summary),
                  const SizedBox(height: 16),
                  BreakdownCard(summary: summary),
                  const SizedBox(height: 16),
                  StoreInventoryCard(summary: summary),
                ],
              ),
            ),
    );
  }
}

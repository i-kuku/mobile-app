import 'package:easy_localization/easy_localization.dart';
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
          'financial_summary'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: CustomColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => context.push('/notifications'),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: financialProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : summary == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  financialProvider.isSavedCopy &&
                          financialProvider.updatedAt == null
                      ? 'summary_needs_internet'.tr()
                      : 'no_financial_summary_records_found'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: financialProvider.load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _FreshnessNote(provider: financialProvider),
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

/// Says when the figures are a saved copy, or may not include the latest
/// entries yet.
class _FreshnessNote extends StatelessWidget {
  const _FreshnessNote({required this.provider});

  final FinancialSummaryProvider provider;

  @override
  Widget build(BuildContext context) {
    final updatedAt = provider.updatedAt;
    final lines = [
      if (provider.isSavedCopy && updatedAt != null)
        'last_updated'.tr(
          args: [DateFormat('d MMM, HH:mm').format(updatedAt.toLocal())],
        ),
      if (provider.hasUnsentChanges) 'figures_may_be_behind'.tr(),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              lines.join(' '),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

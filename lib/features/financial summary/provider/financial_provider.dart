import 'package:flutter/material.dart';
import 'package:ikuku/features/financial%20summary/model/financial_model.dart';
import 'package:ikuku/features/financial%20summary/repository/financial_repo.dart';


class FinancialSummaryProvider extends ChangeNotifier {
  final _repository = FinancialSummaryRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _selectedBatchId; // null = "All Batches"
  String? get selectedBatchId => _selectedBatchId;

  String _selectedTimeframe = '3 Months'; // or 'Life Cycle'
  String get selectedTimeframe => _selectedTimeframe;

  FinancialSummary? _summary;
  FinancialSummary? get summary => _summary;

  void setBatch(String? batchId) {
    _selectedBatchId = batchId;
    _load();
  }

  void setTimeframe(String timeframe) {
    _selectedTimeframe = timeframe;
    _load();
  }

  DateTime? _resolveSince() {
    if (_selectedTimeframe == 'Life Cycle') return null; // no filter, all-time
    if (_selectedTimeframe == '3 Months') {
      final now = DateTime.now();
      return DateTime(now.year, now.month - 3, now.day);
    }
    return null;
  }

  Future<void> load() => _load();

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final since = _resolveSince();

      final totalIncome = await _repository.fetchTotalIncome(
        batchId: _selectedBatchId,
        since: since,
      );

      final expenses = await _repository.fetchExpenseBreakdown(
        batchId: _selectedBatchId,
        since: since,
      );

      final lifecycle = _selectedBatchId != null
          ? await _repository.fetchBatchLifecycleData(_selectedBatchId!)
          : await _repository.fetchAllBatchesLifecycleData();

      final storeInventoryValue = await _repository.fetchStoreInventoryValue();

      _summary = FinancialSummary.compute(
        totalIncome: totalIncome,
        feedsExpense: expenses['feeds']!,
        vaccinesExpense: expenses['vaccines']!,
        othersExpense: expenses['others']!,
        birdsExpense: expenses['birds']!,
        startingChickens: lifecycle['startingChickens']!,
        chickensDied: lifecycle['chickensDied']!,
        storeInventoryValue: storeInventoryValue,
      );
    } catch (e) {
      debugPrint('Error loading financial summary: $e');
      _summary = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
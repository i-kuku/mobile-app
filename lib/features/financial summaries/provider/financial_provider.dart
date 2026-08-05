import 'package:flutter/material.dart';
import 'package:ikuku/features/financial%20summaries/model/financial_summary_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinancialSummaryProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  FinancialSummaryModel? _summary;
  bool _isLoading = false;
  String? _selectedBatchId;
  String _selectedTimeframe = '3 months';

  // Getters
  FinancialSummaryModel? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get selectedBatchId => _selectedBatchId;
  String get selectedTimeframe => _selectedTimeframe;

  // Fetch financial summary from Supabase RPC function
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.rpc(
        'get_financial_summary',
        params: {
          'p_batch_id': _selectedBatchId,
        },
      ) as List<dynamic>;

      if (response.isNotEmpty) {
        _summary = FinancialSummaryModel.fromJson(
          response.first as Map<String, dynamic>,
        );
      } else {
        _summary = null;
      }
    } catch (e) {
      debugPrint('Error loading financial summary: $e');
      _summary = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refreshes data dynamically (call this after adding a sale or expense)
  Future<void> refresh() async {
    await load();
  }

  void setBatch(String? batchId) {
    if (_selectedBatchId != batchId) {
      _selectedBatchId = batchId;
      load();
    }
  }
  void setTimeframe(String timeframe) {
    if (_selectedTimeframe != timeframe) {
      _selectedTimeframe = timeframe;
      notifyListeners();
    }
  }
}
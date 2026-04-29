import 'package:flutter/material.dart';
import 'package:ikuku/features/home/data/model/analytic_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsProvider with ChangeNotifier {
  bool _isLoading = false;
  AnalyticSummary _summary = AnalyticSummary.fromJson({});

  bool get isLoading => _isLoading;
  AnalyticSummary get summary => _summary;

  final _supabase = Supabase.instance.client;

  void toggleLoadingState() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  Future<void> fetchSummary() async {
    final user = _supabase.auth.currentUser;

    final response = await _supabase
        .from('batches')
        .select()
        .eq('user_id', user!.id)
        .order('created_at', ascending: false);

    debugPrint(response.toString());
  }
}

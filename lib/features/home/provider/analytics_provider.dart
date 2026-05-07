import 'package:flutter/material.dart';
import 'package:ikuku/features/home/data/model/analytic_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsProvider with ChangeNotifier {
  bool _isLoading = false;
  AnalyticSummary _summary = AnalyticSummary.fromJson({});

  bool get isLoading => _isLoading;
  AnalyticSummary get summary => _summary;

  final _supabase = Supabase.instance.client;

  User? get user => _supabase.auth.currentUser;
  void toggleLoadingState() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  Future<void> fetchSummary() async {
    try {
      toggleLoadingState();
      if (user == null) throw Exception("Unauthorized user");
      final data = await _supabase
          .from('user_dashboard_stats')
          .select()
          .eq('user_id', user!.id)
          .single();

      _summary = AnalyticSummary.fromJson(data);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      toggleLoadingState();
    }
  }
}

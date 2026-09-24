import 'package:flutter/material.dart';
import 'package:ikuku/features/shop/model/sale_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalesProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<SaleModel> _sales = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SaleModel> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Helper to check if two DateTimes fall on the same local day
  bool _isSameDay(DateTime date1, DateTime date2) {
    final d1 = date1.toLocal();
    final d2 = date2.toLocal();
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  // Calculate today's total sales
  double get todaytotalSales {
    final now = DateTime.now();
    return _sales
        .where((sale) => _isSameDay(sale.createdAt, now))
        .fold(0.0, (sum, sale) => sum + sale.amount);
  }

  // Get today's sales or fallback to the latest 5 sales
  List<SaleModel> get dashboardSales {
    final now = DateTime.now();
    final todaySales =
        _sales.where((sale) => _isSameDay(sale.createdAt, now)).toList();

    if (todaySales.isNotEmpty) {
      return todaySales;
    }
    return _sales.take(5).toList();
  }

  // Group all sales by Date
  Map<String, List<SaleModel>> get salesGroupedByDate {
    final Map<String, List<SaleModel>> grouped = {};
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    for (var sale in _sales) {
      final localDate = sale.createdAt.toLocal();
      String key;
      if (_isSameDay(localDate, now)) {
        key = 'Today';
      } else if (_isSameDay(localDate, yesterday)) {
        key = 'Yesterday';
      } else {
        key = '${localDate.day} ${_getMonthName(localDate.month)}';
      }

      grouped.putIfAbsent(key, () => []).add(sale);
    }
    return grouped;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Future<void> fetchSales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _supabase
          .from('sale')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _sales = (response as List).map((e) => SaleModel.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching sales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSale(SaleModel sale) async {
    _isLoading = true;
    notifyListeners();

    final user = _supabase.auth.currentUser;

    if (user == null) {
      _isLoading = false;
      notifyListeners();
      throw Exception('User is not authenticated.');
    }

    try {
      final saleData = sale.toJson();
      saleData['user_id'] = user.id;

      await _supabase.from('sale').insert(saleData);
      await fetchSales();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
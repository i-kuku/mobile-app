import 'package:flutter/material.dart';
import 'package:ikuku/features/shop/model/sale_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalesProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<SaleModel> _sales = [];
  bool _isLoading = false;

  List<SaleModel> get sales => _sales;
  bool get isLoading => _isLoading;

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
      await fetchLatestSales();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatestSales() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('sale')
          .select()
          .order('created_at', ascending: false)
          .limit(10);

      _sales = (response as List)
          .map((data) => SaleModel.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching sales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

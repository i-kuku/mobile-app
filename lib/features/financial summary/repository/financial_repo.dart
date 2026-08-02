import 'package:supabase_flutter/supabase_flutter.dart';

class FinancialSummaryRepository {
  final _client = Supabase.instance.client;

  /// Sums chicken sales income (batch_records.sales_amount) for the given
  /// batch (or all batches if batchId is null) within the given timeframe
  /// (or all-time if since is null).
  Future<int> fetchTotalIncome({String? batchId, DateTime? since}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    var query = _client
        .from('batch_records')
        .select('sales_amount, batch_id, daily_records!batch_records_daily_record_id_fkey(report_date, user_id)')
        .eq('daily_records.user_id', userId);

    if (batchId != null) {
      query = query.eq('batch_id', batchId);
    }

    final response = await query;
    final rows = List<Map<String, dynamic>>.from(response);

    int total = 0;
    for (final row in rows) {
      final dailyRecord = row['daily_records'] as Map<String, dynamic>?;
      final rawDate = dailyRecord?['report_date'] as String?;

      if (since != null && rawDate != null) {
        final reportDate = DateTime.parse(rawDate);
        if (reportDate.isBefore(since)) continue;
      }

      final salesAmount = row['sales_amount'];
      if (salesAmount is int) {
        total += salesAmount;
      } else if (salesAmount is double) {
        total += salesAmount.toInt();
      }
    }

    return total;
  }

  /// Returns {'feeds': X, 'vaccines': Y, 'others': Z, 'birds': W}
  Future<Map<String, int>> fetchExpenseBreakdown({
    String? batchId,
    DateTime? since,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return {'feeds': 0, 'vaccines': 0, 'others': 0, 'birds': 0};
    }

    var batchQuery = _client.from('batches').select('id, purchase_cost').eq('user_id', userId);
    if (batchId != null) {
      batchQuery = batchQuery.eq('id', batchId);
    }
    final batchRows = List<Map<String, dynamic>>.from(await batchQuery);

    int birdsExpense = 0;
    for (final row in batchRows) {
      final cost = row['purchase_cost'];
      if (cost is num) birdsExpense += cost.toInt();
    }

    final inventoryResponse = await _client
        .from('inventory_items')
        .select('name, price')
        .eq('user_id', userId);
    final priceByName = <String, num>{};
    for (final item in List<Map<String, dynamic>>.from(inventoryResponse)) {
      final name = item['name'] as String?;
      final price = item['price'];
      if (name != null && price is num) {
        priceByName[name] = price;
      }
    }

    var reportQuery = _client
        .from('batch_records')
        .select('''
          batch_id,
          feeds_used,
          vaccines_used,
          other_materials_used,
          daily_records!batch_records_daily_record_id_fkey(report_date, user_id)
        ''')
        .eq('daily_records.user_id', userId);
    if (batchId != null) {
      reportQuery = reportQuery.eq('batch_id', batchId);
    }
    final reportRows = List<Map<String, dynamic>>.from(await reportQuery);

    int feedsExpense = 0;
    int vaccinesExpense = 0;
    int othersExpense = 0;

    for (final row in reportRows) {
      final dailyRecord = row['daily_records'] as Map<String, dynamic>?;
      final rawDate = dailyRecord?['report_date'] as String?;

      if (since != null && rawDate != null) {
        final reportDate = DateTime.parse(rawDate);
        if (reportDate.isBefore(since)) continue;
      }

      feedsExpense += _sumUsageCost(row['feeds_used'], priceByName);
      vaccinesExpense += _sumUsageCost(row['vaccines_used'], priceByName);
      othersExpense += _sumUsageCost(row['other_materials_used'], priceByName);
    }

    return {
      'feeds': feedsExpense,
      'vaccines': vaccinesExpense,
      'others': othersExpense,
      'birds': birdsExpense,
    };
  }

  int _sumUsageCost(dynamic usageList, Map<String, num> priceByName) {
    if (usageList is! List) return 0;

    int total = 0;
    for (final entry in usageList) {
      if (entry is! Map) continue;
      final name = entry['name'] as String?;
      final quantityRaw = entry['quantity'];

      if (name == null || quantityRaw == null) continue;

      final quantity = quantityRaw is num
          ? quantityRaw
          : num.tryParse(quantityRaw.toString()) ?? 0;

      final price = priceByName[name];
      if (price != null) {
        total += (quantity * price).toInt();
      }
    }
    return total;
  }

  /// Returns {'startingChickens': X, 'chickensDied': Y} for a single batch.
  Future<Map<String, int>> fetchBatchLifecycleData(String batchId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {'startingChickens': 0, 'chickensDied': 0};

    final batchRow = await _client
        .from('batches')
        .select('initial_count')
        .eq('id', batchId)
        .eq('user_id', userId)
        .maybeSingle();

    final startingChickens = (batchRow?['initial_count'] as int?) ?? 0;

    final reportRows = await _client
        .from('batch_records')
        .select('''
          chickens_died,
          daily_records!batch_records_daily_record_id_fkey(user_id)
        ''')
        .eq('batch_id', batchId)
        .eq('daily_records.user_id', userId);

    int totalDied = 0;
    for (final row in List<Map<String, dynamic>>.from(reportRows)) {
      final died = row['chickens_died'];
      if (died is int) totalDied += died;
      if (died is double) totalDied += died.toInt();
    }

    return {'startingChickens': startingChickens, 'chickensDied': totalDied};
  }

  Future<int> fetchStoreInventoryValue() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _client
        .from('inventory_items')
        .select('quantity, price')
        .eq('user_id', userId);

    int total = 0;
    for (final item in List<Map<String, dynamic>>.from(response)) {
      final quantity = item['quantity'];
      final price = item['price'];
      if (quantity is num && price is num) {
        total += (quantity * price).toInt();
      }
    }

    return total;
  }
  /// For "All Batches": sums starting count and deaths across every batch.
Future<Map<String, int>> fetchAllBatchesLifecycleData() async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) return {'startingChickens': 0, 'chickensDied': 0};

  final batchRows = await _client
      .from('batches')
      .select('id, initial_count')
      .eq('user_id', userId);

  int startingChickens = 0;
  final batchIds = <String>[];
  for (final row in List<Map<String, dynamic>>.from(batchRows)) {
    final count = row['initial_count'];
    if (count is int) startingChickens += count;
    batchIds.add(row['id'] as String);
  }

  if (batchIds.isEmpty) {
    return {'startingChickens': 0, 'chickensDied': 0};
  }

  final reportRows = await _client
      .from('batch_records')
      .select('''
        chickens_died,
        batch_id,
        daily_records!batch_records_daily_record_id_fkey(user_id)
      ''')
      .inFilter('batch_id', batchIds)
      .eq('daily_records.user_id', userId);

  int totalDied = 0;
  for (final row in List<Map<String, dynamic>>.from(reportRows)) {
    final died = row['chickens_died'];
    if (died is int) totalDied += died;
    if (died is double) totalDied += died.toInt();
  }

  return {'startingChickens': startingChickens, 'chickensDied': totalDied};
}
}
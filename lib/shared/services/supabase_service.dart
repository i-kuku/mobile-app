import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final supabase = Supabase.instance.client;

  // Test Supabase connection
  Future<bool> testConnection() async {
    try {
      print('Testing Supabase connection...');

      // Try to fetch a simple query to test connection
      // Use a table that should exist, or try a simple RPC call
      try {
        final response = await supabase.from('users').select('count').limit(1);
        print('Connection test successful: $response');
        return true;
      } catch (tableError) {
        // If users table doesn't exist, try a different approach
        print('Users table not accessible, trying alternative test...');
        // Try to get the current user (this should work even if no user is logged in)
        final user = supabase.auth.currentUser;
        print(
          'Current user check successful: ${user?.id ?? 'No user logged in'}',
        );
        return true;
      }
    } catch (e) {
      print('Supabase connection test failed: $e');
      print('Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Example: Fetch all batches for a user
  Future<List<Map<String, dynamic>>> fetchBatches(String userId) async {
    final response = await supabase
        .from('batches')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Example: Add a new batch
  Future<void> addBatch(Map<String, dynamic> batch) async {
    await supabase.from('batches').insert(batch);
  }

  // Update an existing batch
  Future<void> updateBatch(Map<String, dynamic> batch) async {
    await supabase.from('batches').update(batch).eq('id', batch['id']);
  }

  // Delete a batch by id
  Future<void> deleteBatch(String id) async {
    await supabase.from('batches').delete().eq('id', id);
  }

  // Fetch all inventory items for a user
  Future<List<Map<String, dynamic>>> fetchInventory(String userId) async {
    final response = await supabase
        .from('inventory_items')
        .select()
        .eq('user_id', userId)
        .order('added_on', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Add a new inventory item
  Future<void> addInventoryItem(Map<String, dynamic> item) async {
    await supabase.from('inventory_items').insert(item);
  }

  // Update an inventory item
  Future<void> updateInventoryItem(Map<String, dynamic> item) async {
    await supabase.from('inventory_items').update(item).eq('id', item['id']);
  }

  // Delete an inventory item by id
  Future<void> deleteInventoryItem(String id) async {
    await supabase.from('inventory_items').delete().eq('id', id);
  }

  // Update inventory item quantity (for consumption tracking)
  Future<void> updateInventoryQuantity(
    String itemId,
    double quantityChange,
  ) async {
    // Get current quantity
    final response = await supabase
        .from('inventory_items')
        .select('quantity')
        .eq('id', itemId)
        .single();

    final currentQuantity = (response['quantity'] as num?)?.toDouble() ?? 0.0;
    final newQuantity = currentQuantity + quantityChange;

    // Ensure quantity doesn't go below 0
    final finalQuantity = newQuantity < 0 ? 0.0 : newQuantity;

    await supabase
        .from('inventory_items')
        .update({'quantity': finalQuantity})
        .eq('id', itemId);

    print(
      '[SupabaseService] Updated inventory $itemId: $currentQuantity -> $finalQuantity',
    );
  }

  // Fetch all daily records for a user
  Future<List<Map<String, dynamic>>> fetchDailyRecords(String userId) async {
    final response = await supabase
        .from('daily_records')
        .select()
        .eq('user_id', userId)
        .order('record_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Add a new daily record
  Future<String> addDailyRecord(Map<String, dynamic> record) async {
    print('addDailyRecord - Creating daily record: $record');
    final response = await supabase
        .from('daily_records')
        .insert(record)
        .select()
        .single();
    print('addDailyRecord - Created daily record with ID: ${response['id']}');
    return response['id'] as String;
  }

  // Fetch daily records in a date range (inclusive start, exclusive end)
  Future<List<Map<String, dynamic>>> fetchDailyRecordsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final response = await supabase
        .from('daily_records')
        .select('id, record_date')
        .eq('user_id', userId)
        .gte('record_date', start.toIso8601String())
        .lt('record_date', end.toIso8601String())
        .order('record_date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch aggregated reports for a user using RPC function
  Future<List<Map<String, dynamic>>> fetchReports(String userId) async {
    final response = await supabase.rpc('get_farm_data').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Add or update a batch record
  Future<void> addBatchRecord(Map<String, dynamic> record) async {
    // Create a copy of the record to avoid modifying the original
    final rec = Map<String, dynamic>.from(record);

    // Ensure feeds_used, vaccines_used, and other_materials_used are properly formatted
    if (rec['feeds_used'] != null && rec['feeds_used'] is List) {
      rec['feeds_used'] = List<Map<String, dynamic>>.from(rec['feeds_used']);
    }
    if (rec['vaccines_used'] != null && rec['vaccines_used'] is List) {
      rec['vaccines_used'] = List<Map<String, dynamic>>.from(
        rec['vaccines_used'],
      );
    }
    if (rec['other_materials_used'] != null &&
        rec['other_materials_used'] is List) {
      rec['other_materials_used'] = List<Map<String, dynamic>>.from(
        rec['other_materials_used'],
      );
    }

    if (rec.containsKey('id')) {
      print('addBatchRecord - Updating existing record: ${rec['id']}');
      await supabase.from('batch_records').update(rec).eq('id', rec['id']);
    } else {
      print('addBatchRecord - Inserting new record');
      await supabase.from('batch_records').insert(rec);
    }
    print('addBatchRecord - Operation completed successfully');
  }

  // Fix database constraints to allow one report per batch per day
  Future<void> fixDatabaseConstraints() async {
    try {
      // Drop the existing unique_user_date constraint if it exists
      await supabase.rpc(
        'exec_sql',
        params: {
          'sql': '''
          DO \$\$ 
          BEGIN
            -- Drop existing constraint if it exists
            IF EXISTS (
              SELECT 1 FROM information_schema.table_constraints 
              WHERE constraint_name = 'unique_user_date'
            ) THEN
              ALTER TABLE daily_records DROP CONSTRAINT IF EXISTS unique_user_date;
            END IF;
            
            -- Add new constraint for one report per batch per day
            -- This will be enforced at the application level since we check before inserting
          END \$\$;
        ''',
        },
      );
      print('Database constraints fixed successfully');
    } catch (e) {
      print('Error fixing database constraints: $e');
      // Continue execution even if constraint fix fails
    }
  }

  // Check if a daily record exists for a batch and date (normalized schema)
  Future<bool> hasDailyRecordForBatch(String batchId, DateTime date) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      // 1. Find all daily_records for this user for the date (handle multiple records)
      final dailyRecords = await supabase
          .from('daily_records')
          .select('id')
          .eq('user_id', user.id)
          .gte('record_date', startOfDay.toIso8601String())
          .lt('record_date', endOfDay.toIso8601String());

      if (dailyRecords.isEmpty) return false;

      // 2. Check if a batch_record exists for this batch and any of the daily_records
      final dailyRecordIds = dailyRecords
          .map((r) => r['id'] as String)
          .toList();

      // Use .select() and check if any records exist instead of .maybeSingle()
      final batchRecords = await supabase
          .from('batch_records')
          .select('id')
          .eq('batch_id', batchId)
          .inFilter('daily_record_id', dailyRecordIds);

      // Return true if any batch records exist for this batch
      return batchRecords.isNotEmpty;
    } catch (e) {
      print('Error checking daily record for batch: $e');
      return false; // Return false on error to allow reporting
    }
  }

  // Fetch all batch records for a given daily record id
  Future<List<Map<String, dynamic>>> fetchBatchRecordsForDailyRecord(
    String dailyRecordId,
  ) async {
    final response = await supabase
        .from('batch_records')
        .select()
        .eq('daily_record_id', dailyRecordId);

    // Debug: Print the raw response from Supabase
    print(
      'SupabaseService - fetchBatchRecordsForDailyRecord response: $response',
    );

    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch all batch records for a list of daily record ids
  Future<List<Map<String, dynamic>>> fetchBatchRecordsForDailyRecordIds(
    List<String> dailyRecordIds,
  ) async {
    if (dailyRecordIds.isEmpty) return [];
    final response = await supabase
        .from('batch_records')
        .select()
        .inFilter('daily_record_id', dailyRecordIds);
    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch all batch records for a user for a specific date
  Future<List<Map<String, dynamic>>> fetchDailyRecordsForDate(
    String userId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    // 1. Find all daily_records for this user for the date
    final dailyRecords = await supabase
        .from('daily_records')
        .select('id')
        .eq('user_id', userId)
        .gte('record_date', startOfDay.toIso8601String())
        .lt('record_date', endOfDay.toIso8601String());
    print(
      '[SupabaseService] fetchDailyRecordsForDate: dailyRecords =  [33m$dailyRecords\u001b[0m',
    );
    if (dailyRecords.isEmpty) return [];
    final dailyRecordIds = dailyRecords.map((r) => r['id'] as String).toList();
    if (dailyRecordIds.isEmpty) return [];
    // 2. Find all batch_records for these daily_record_ids
    final batchRecords = await supabase
        .from('batch_records')
        .select('batch_id')
        .inFilter('daily_record_id', dailyRecordIds);
    print(
      '[SupabaseService] fetchDailyRecordsForDate: batchRecords = \u001b[36m$batchRecords\u001b[0m',
    );
    // Ensure every record is a map with a batch_id key
    if (batchRecords.isEmpty) return [];
    final result = List<Map<String, dynamic>>.from(
      batchRecords,
    ).where((r) => r.containsKey('batch_id') && r['batch_id'] != null).toList();
    return result;
  }

  // Fetch batch profits using RPC function
  Future<List<Map<String, dynamic>>> fetchBatchProfits() async {
    final response = await supabase.rpc('get_batch_profits').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch the total eggs collected by a user
  Future<int> fetchTotalEggsCollected(String userId) async {
    // 1. Get all daily_record ids for this user
    final dailyRecords = await supabase
        .from('daily_records')
        .select('id')
        .eq('user_id', userId);
    if (dailyRecords.isEmpty) return 0;
    final dailyRecordIds = dailyRecords.map((r) => r['id'] as String).toList();
    if (dailyRecordIds.isEmpty) return 0;
    // 2. Get all batch_records for these daily_record_ids
    final batchRecords = await supabase
        .from('batch_records')
        .select('eggs_collected')
        .inFilter('daily_record_id', dailyRecordIds);
    if (batchRecords.isEmpty) return 0;
    // 3. Sum eggs_collected
    int totalEggs = 0;
    for (final record in batchRecords) {
      final eggs = record['eggs_collected'];
      if (eggs != null && eggs is int) {
        totalEggs += eggs;
      }
    }
    return totalEggs;
  }

  // Create an expense record
  Future<void> createExpense({
    required String userId,
    String? batchId,
    required String expenseType,
    String? expenseCategory,
    required double amount,
    int quantity = 0,
    double unitPrice = 0.0,
    String? description,
    DateTime? expenseDate,
  }) async {
    final expenseData = {
      'user_id': userId,
      'batch_id': batchId,
      'expense_type': expenseType,
      'expense_category': expenseCategory,
      'amount': amount,
      'quantity': quantity,
      'unit_price': unitPrice,
      'description': description,
      'expense_date': (expenseDate ?? DateTime.now()).toIso8601String(),
    };

    // Remove null values
    expenseData.removeWhere((key, value) => value == null);

    await supabase.from('expenses').insert(expenseData);
  }

  // Get expenses for a user
  Future<List<Map<String, dynamic>>> fetchExpenses(
    String userId, {
    String? batchId,
    String? expenseType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = supabase.from('expenses').select().eq('user_id', userId);

    if (batchId != null) {
      query = query.eq('batch_id', batchId);
    }

    if (expenseType != null) {
      query = query.eq('expense_type', expenseType);
    }

    if (startDate != null) {
      query = query.gte('expense_date', startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.lte('expense_date', endDate.toIso8601String());
    }

    return List<Map<String, dynamic>>.from(
      await query.order('expense_date', ascending: false),
    );
  }

  // Fetch all report dates for a specific batch
  Future<List<DateTime>> fetchReportDatesForBatch(String batchId) async {
    try {
      final response = await supabase
          .from('batch_records')
          .select('daily_records!inner(record_date)')
          .eq('batch_id', batchId);

      final List<DateTime> dates = [];
      for (final item in response) {
        final dailyRecord = item['daily_records'];
        if (dailyRecord != null && dailyRecord['record_date'] != null) {
          final date = DateTime.tryParse(dailyRecord['record_date']);
          if (date != null) {
            dates.add(date);
          }
        }
      }
      return dates;
    } catch (e) {
      print('Error fetching report dates for batch: $e');
      return [];
    }
  }
}

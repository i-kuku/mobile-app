import 'package:supabase_flutter/supabase_flutter.dart';

class ReportsRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchRecentReports({int limit = 5}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('batch_records')
        .select('''
          id,
          batch_id,
          daily_records!batch_records_daily_record_id_fkey(report_date, user_id),
          batches!batch_records_batch_id_fkey(name, type_of_bird)
        ''')
        .eq('daily_records.user_id', userId)
        .order('daily_record_id', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchReportDetail(String reportId) async {
    final userId = _client.auth.currentUser?.id;   // <-- added
    if (userId == null) return null;                // <-- added

    final response = await _client
        .from('batch_records')
        .select('''
          *,
          daily_records!batch_records_daily_record_id_fkey(report_date, user_id),
          batches!batch_records_batch_id_fkey(name, type_of_bird)
        ''')
        .eq('id', reportId)
        .eq('daily_records.user_id', userId)   // <-- added
        .maybeSingle();

    return response;
  }
  Future<List<Map<String, dynamic>>> fetchAllReports() async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) return [];

  final response = await _client
      .from('batch_records')
      .select('''
        id,
        batch_id,
        chickens_curled,
        chickens_sold,
        chickens_died,
        chickens_stolen,
        eggs_collected,
        daily_records!batch_records_daily_record_id_fkey(report_date, user_id),
        batches!batch_records_batch_id_fkey(name, type_of_bird)
      ''')
      .eq('daily_records.user_id', userId)
      .order('daily_record_id', ascending: false);

  return List<Map<String, dynamic>>.from(response);
}
}
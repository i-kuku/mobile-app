/// The developer account and sample farm the dev backend starts with.
///
/// Only used by `DevBackend`, which exists in debug builds run with
/// `--dart-define=IKUKU_DEV_BACKEND=true`. None of this ever reaches
/// Supabase.
abstract final class DevSeed {
  static const email = 'dev@ikuku.test';
  static const password = 'ikuku-dev-123';
  static const fullName = 'Dev Farmer';

  static const userId = '00000000-0000-4000-8000-000000000001';
  static const farmId = '00000000-0000-4000-8000-0000000000f1';
  static const layersBatchId = '00000000-0000-4000-8000-0000000000b1';
  static const broilersBatchId = '00000000-0000-4000-8000-0000000000b2';
  static const layersMashId = '00000000-0000-4000-8000-0000000000a1';
  static const starterId = '00000000-0000-4000-8000-0000000000a2';
  static const vaccineId = '00000000-0000-4000-8000-0000000000a3';
  static const traysId = '00000000-0000-4000-8000-0000000000a4';

  /// A fresh copy of the dev backend's data, dated relative to [now] so the
  /// app's date-based logic (reports, reminders) behaves the same any day.
  static Map<String, dynamic> build({DateTime? now}) {
    final today = now ?? DateTime.now();
    String at(int daysAgo) =>
        today.subtract(Duration(days: daysAgo)).toUtc().toIso8601String();
    String date(int daysAgo) =>
        today.subtract(Duration(days: daysAgo)).toIso8601String().split('T')[0];

    // A report for the layers on each of the last three days.
    final dailyRecords = <Map<String, dynamic>>[];
    final batchRecords = <Map<String, dynamic>>[];
    for (final (day, eggs, died) in [(1, 252, 1), (2, 247, 0), (3, 255, 0)]) {
      final dailyId = '00000000-0000-4000-8000-0000000000d$day';
      dailyRecords.add({
        'id': dailyId,
        'user_id': userId,
        'record_date': date(day),
        'report_date': date(day),
        'created_at': at(day),
      });
      batchRecords.add({
        'id': '00000000-0000-4000-8000-0000000000e$day',
        'daily_record_id': dailyId,
        'batch_id': layersBatchId,
        'chicken_reduction': died > 0,
        'chickens_curled': 0,
        'chickens_sold': 0,
        'chickens_died': died,
        'chickens_stolen': 0,
        'egg_collection': true,
        'eggs_collected': eggs,
        'grade_eggs': false,
        'eggs_small': 0,
        'eggs_deformed': 0,
        'eggs_standard': 0,
        'eggs_broken': 2,
        'notes': null,
        'feeds_used': [
          {'id': layersMashId, 'name': 'Layers Mash', 'quantity': 20},
        ],
        'vaccines_used': <Map<String, dynamic>>[],
        'other_materials_used': <Map<String, dynamic>>[],
        'sales_amount': 0,
        'losses_breakdown': <Map<String, dynamic>>[],
        'gains_amount': 0,
      });
    }

    return {
      'auth_users': [
        {
          'id': userId,
          'email': email,
          'password': password,
          'created_at': at(200),
          'user_metadata': {'full_name': fullName},
        },
      ],
      'refresh_tokens': <String, dynamic>{},
      'sequences': {'sale': 3},
      'tables': {
        'users': [
          {
            'id': userId,
            'full_name': fullName,
            'phone_number': '0700000000',
            'avatar_url': null,
            'recovery_question': 'question_1',
            'recovery_answer': 'kuku',
            'recovery_phone_1': null,
            'recovery_phone_2': null,
            'created_at': at(200),
          },
        ],
        'farms': [
          {
            'id': farmId,
            'user_id': userId,
            'farm_name': 'Dev Farm',
            'farm_location': 'Nakuru',
            'created_at': at(200),
          },
        ],
        'batches': [
          {
            'id': layersBatchId,
            'user_id': userId,
            'name': 'Layers A',
            'type_of_bird': 'layer',
            'initial_count': 300,
            'age': 18,
            'age_unit': 'Weeks',
            'purchase_cost': 45000,
            // Old enough for its vaccination reminder to be due.
            'created_at': at(120),
          },
          {
            'id': broilersBatchId,
            'user_id': userId,
            'name': 'Broilers B',
            'type_of_bird': 'broiler',
            'initial_count': 150,
            'age': 3,
            'age_unit': 'Weeks',
            'purchase_cost': 18000,
            'created_at': at(21),
          },
        ],
        'inventory_items': [
          // Under 30 kg, so it shows as low on stock.
          _item(layersMashId, 'Layers Mash', 'feeds', 25, 'Kg', 75, at(10)),
          _item(starterId, 'Broiler Starter', 'feeds', 120, 'Kg', 82, at(21)),
          _item(
            vaccineId,
            'Newcastle Vaccine',
            'medicines',
            4,
            'L',
            900,
            at(30),
          ),
          _item(traysId, 'Egg Trays', 'others', 60, 'Mifuko', 15, at(30)),
        ],
        'daily_records': dailyRecords,
        'batch_records': batchRecords,
        'sale': [
          _sale(1, 'eggs', null, 210, 2100, at(1)),
          _sale(2, 'chicken', 'layer', 5, 3500, at(3)),
          _sale(3, 'manure', null, 4, 800, at(5)),
        ],
        'user_notifications': <Map<String, dynamic>>[],
        'expenses': <Map<String, dynamic>>[],
      },
    };
  }

  static Map<String, dynamic> _item(
    String id,
    String name,
    String category,
    int quantity,
    String unit,
    num price,
    String addedOn,
  ) => {
    'id': id,
    'user_id': userId,
    'name': name,
    'category': category,
    'quantity': quantity,
    'unit': unit,
    'price': price,
    'added_on': addedOn,
  };

  static Map<String, dynamic> _sale(
    int id,
    String type,
    String? subType,
    int quantity,
    num amount,
    String createdAt,
  ) => {
    'id': id,
    'user_id': userId,
    'sale_type': type,
    'sub_type': subType,
    'quantity': quantity,
    'amount': amount,
    'created_at': createdAt,
  };
}

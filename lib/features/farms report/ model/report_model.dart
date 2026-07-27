import 'package:uuid/uuid.dart';

class Report {
  final String id;
  final String dailyRecordId;
  final String batchId;
  final bool chickenReduction;
  final int? chickensCurled;
  final int? chickensSold;
  final int? chickensDied;
  final int? chickensStolen;
  final bool eggCollection;
  final int? eggsCollected;
  final bool gradeEggs;
  final int? eggsSmall;
  final int? eggsDeformed;
  final int? eggsStandard;
  final int? eggsBroken;
  final String? notes;
  final List<Map<String, dynamic>> feedsUsed;
  final List<Map<String, dynamic>> vaccinesUsed;
  final List<Map<String, dynamic>> otherMaterialsUsed;
  final int? salesAmount;
  final List<Map<String, dynamic>> lossesBreakdown;
  final int? gainsAmount;

  Report({
    required this.id,
    required this.dailyRecordId,
    required this.batchId,
    required this.chickenReduction,
    this.chickensCurled,
    this.chickensSold,
    this.chickensDied,
    this.chickensStolen,
    required this.eggCollection,
    this.eggsCollected,
    required this.gradeEggs,
    this.eggsSmall,
    this.eggsDeformed,
    this.eggsStandard,
    this.eggsBroken,
    this.notes,
   this.feedsUsed=const [],
   this.vaccinesUsed = const [],
     this.otherMaterialsUsed = const [],
    this.salesAmount,
   this.lossesBreakdown = const [],
    this.gainsAmount,
  });

  factory Report.fromJson(Map<String, dynamic>json) => Report(
    id: json['id'] as String,
    dailyRecordId: json['daily_record_id'] as String,
    batchId: json['batch_id'] as String,
    chickenReduction: json['chicken_reduction'] as bool? ?? false,
    chickensSold: json['chicken_sold'] as int? ?? 0,
    chickensCurled: json['chickens_curled'] as int? ?? 0,
    chickensDied: json['chickens_died'] as int? ?? 0,
    chickensStolen: json['chickens_stolen'] as int? ?? 0,
    eggCollection: json['egg_collection'] as bool? ?? false,
    eggsCollected: json['eggs_collected'] as int? ?? 0,
    gradeEggs: json['grade_eggs'] as bool? ?? false,
    eggsSmall: json['eggs_small'] as int? ?? 0,
    eggsDeformed: json['eggs_deformed'] as int? ?? 0,
    eggsStandard: json['eggs_standard'] as int? ?? 0,
    notes: json['notes'] as String?,
    eggsBroken: json['eggs_broken'] as int? ?? 0,
    feedsUsed: (json['feeds_used'] as List<dynamic>?) ?.map((item) => item as Map<String,dynamic>).toList() ?? const [],
    vaccinesUsed: (json['vaccines_used'] as List<dynamic>?) ?.map((item)=>item as Map<String,dynamic>).toList() ?? const [],
    otherMaterialsUsed: (json['other_materials_used'] as List<dynamic>?)?.map((item) => item as Map<String, dynamic>).toList() ?? const [],
    salesAmount: json['sales_amount'] as int? ?? 0,
    lossesBreakdown: (json['losses_breakdown'] as List<dynamic>?) ?.map((item)=>item as Map<String,dynamic>).toList() ?? const [],
    gainsAmount: json['gains_amount'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'daily_record_id': dailyRecordId,
    'batch_id': batchId,
    'chicken_reduction': chickenReduction,
    'chickens_curled': chickensCurled,
    'chickens_sold': chickensSold,
    'chickens_died': chickensDied,
    'chickens_stolen': chickensStolen,
    'egg_collection': eggCollection,
    'eggs_collected': eggsCollected,
    'grade_eggs': gradeEggs,
    'eggs_small': eggsSmall,
    'eggs_deformed': eggsDeformed,
    'eggs_standard': eggsStandard,
    'eggs_broken': eggsBroken,
    'notes': notes,
    'feeds_used': feedsUsed,
    'vaccines_used': vaccinesUsed,
    'other_materials_used': otherMaterialsUsed,
    'sales_amount': salesAmount,
    'losses_breakdown': lossesBreakdown,
    'gains_amount': gainsAmount,
  };

  static Report empty({required String id, required String batchId, required String dailyRecordId}){
    return Report(
      id: Uuid().v4(),
      dailyRecordId: dailyRecordId,
      batchId: batchId,
      chickenReduction: false,
      eggCollection: false,
      gradeEggs: false,
    );
  }
}

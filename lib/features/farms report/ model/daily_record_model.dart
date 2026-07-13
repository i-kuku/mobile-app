import 'package:uuid/uuid.dart';

class DailyRecord {
  final String id;
  final String userId;
  final DateTime reportDate;
  final DateTime recordDate;
  final DateTime? createdAt;

  DailyRecord({
    required this.id,
    required this.userId,
    required this.reportDate,
    required this.recordDate,
    this.createdAt,
  });

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    recordDate: DateTime.parse(json['record_date'] as String),
    reportDate: DateTime.parse(json['report_date'] as String),
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'record_date': recordDate.toIso8601String().split('T')[0],
    'report_date': reportDate.toIso8601String().split('T')[0],
  };
  static DailyRecord empty(String userId) {
    final today = DateTime.now();
    return DailyRecord(
      id: const Uuid().v4(),
      userId: userId,
      recordDate: today,
      reportDate: today,
    );
  }
}

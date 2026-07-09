import 'package:uuid/uuid.dart';

class Report {
  final String id;
  final String userId;
  final DateTime date;
  final int totalChickens;
  final int totalDeaths;
  final int totalBatches;

  Report({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalChickens,
    required this.totalBatches,
    required this.totalDeaths,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    date: DateTime.parse(json['date'] as String),
    totalChickens: json['total_chickens'] as int,
    totalBatches: json['total_batches'] as int,
    totalDeaths: json['total_deaths'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'date': date.toIso8601String(),
    'total_chickens': totalChickens,
    'total_deaths': totalDeaths,
    'total_batches': totalBatches,
  };
  static Report empty(String userId) => Report(
    id: const Uuid().v4(),
    userId: userId,
    date: DateTime.now(),
    totalChickens: 0,
    totalDeaths: 0,
    totalBatches: 0,
  );
}

class ReportListItem {
  final String id;
  final String batchName;
  final String batchType;
  final DateTime reportDate;
  final int totalReductions;
  final int eggsCollected;

  const ReportListItem({
    required this.id,
    required this.batchName,
    required this.batchType,
    required this.reportDate,
    required this.totalReductions,
    required this.eggsCollected,
  });

  factory ReportListItem.fromJson(Map<String, dynamic> json) {
    final batch = json['batches'] as Map<String, dynamic>?;
    final dailyRecord = json['daily_records'] as Map<String, dynamic>?;
    final rawDate = dailyRecord?['report_date'] as String?;

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    final curled = toInt(json['chickens_curled']);
    final sold = toInt(json['chickens_sold']);
    final died = toInt(json['chickens_died']);
    final stolen = toInt(json['chickens_stolen']);

    return ReportListItem(
      id: json['id'] as String,
      batchName: (batch?['name'] as String?) ?? 'Unknown batch',
      batchType: (batch?['type_of_bird'] as String?) ?? '',
      reportDate: rawDate != null ? DateTime.parse(rawDate) : DateTime.now(),
      totalReductions: curled + sold + died + stolen,
      eggsCollected: toInt(json['eggs_collected']),
    );
  }
}
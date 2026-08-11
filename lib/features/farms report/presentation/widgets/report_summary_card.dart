import 'package:flutter/material.dart';

class ReportSummary {
  final String id;
  final String batchName;
  final String batchType;
  final String reportDate; // already formatted, e.g. "2026-07-06"

  const ReportSummary({
    required this.id,
    required this.batchName,
    required this.batchType,
    required this.reportDate,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    final batch = json['batches'] as Map<String, dynamic>?;
    final dailyRecord = json['daily_records'] as Map<String, dynamic>?;
    final rawDate = dailyRecord?['report_date'] as String?;

    return ReportSummary(
      id: json['id'] as String,
      batchName: (batch?['name'] as String?) ?? 'Unknown batch',
      batchType: (batch?['type_of_bird'] as String?) ?? '',
      reportDate: rawDate != null ? rawDate.split('T').first : '',
    );
  }
}

class ReportSummaryCard extends StatelessWidget {
  final ReportSummary report;
  final VoidCallback onTap;

  const ReportSummaryCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.batchName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              '${report.reportDate} • ${report.batchType}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
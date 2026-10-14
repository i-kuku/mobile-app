import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/farms%20report/%20model/report_list_item.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/features/farms%20report/repository/reports_repository.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});

  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  final _repository = ReportsRepository();
  late List<ReportListItem> _reports;
  StreamSubscription<void>? _changes;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _reports = _loadReports();
    _changes = _repository.changes.listen((_) => _reload());
    _repository.refresh();
  }

  @override
  void dispose() {
    _changes?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<ReportListItem> _loadReports() =>
      _repository.fetchAllReports().map(ReportListItem.fromJson).toList();

  void _reload() {
    if (mounted) setState(() => _reports = _loadReports());
  }

  Future<void> _openReport(BuildContext context, ReportListItem report) async {
    final detail = _repository.fetchReportDetail(report.id);
    final batchId = detail?['batch_id'] as String?;
    final batchRow = batchId == null ? null : _repository.fetchBatch(batchId);
    if (detail == null || batchRow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('something_went_wrong_message'.tr())),
      );
      return;
    }

    final reports = context.read<FarmReportProvider>();
    reports.loadReportForEditing(detail);
    reports.setBatch(ChickenBatch.fromJson(batchRow));
    await context.push('/Farm_Report_Entry_Screen', extra: batchId);
    _reload();
  }

  Map<String, List<ReportListItem>> _groupByDate(List<ReportListItem> reports) {
    final grouped = <String, List<ReportListItem>>{};
    for (final report in reports) {
      final key = DateFormat('EEEE, MMMM d, yyyy').format(report.reportDate);
      grouped.putIfAbsent(key, () => []).add(report);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9fa),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CustomColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'all_reports'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: CustomColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: CustomColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'search_reports'.tr(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                var reports = _reports;
                if (_searchQuery.isNotEmpty) {
                  reports = reports
                      .where(
                        (r) => r.batchName.toLowerCase().contains(_searchQuery),
                      )
                      .toList();
                }

                if (reports.isEmpty) {
                  return Center(
                    child: Text(
                      'no_reports_found'.tr(),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                final grouped = _groupByDate(reports);

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: grouped.entries.expand((entry) {
                    return [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ...entry.value.map(
                        (report) => _ReportCard(
                          report: report,
                          onTap: () => _openReport(context, report),
                        ),
                      ),
                    ];
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportListItem report;
  final VoidCallback onTap;

  const _ReportCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.batchName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.batchType.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    if (report.totalReductions > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_down,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${report.totalReductions} reductions',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ] else if (report.eggsCollected > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.egg, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '${report.eggsCollected} Eggs',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

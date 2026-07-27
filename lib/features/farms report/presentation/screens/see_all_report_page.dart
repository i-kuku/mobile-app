import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/farms%20report/%20model/report_list_item.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:intl/intl.dart';
import 'package:ikuku/features/farms%20report/repository/reports_repository.dart';

import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});

  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  final _repository = ReportsRepository();
  late Future<List<ReportListItem>> _reportsFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _reportsFuture = _loadReports();
  }

  Future<List<ReportListItem>> _loadReports() async {
    final raw = await _repository.fetchAllReports();
    return raw.map(ReportListItem.fromJson).toList();
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
          'All Reports',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: CustomColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: CustomColors.primary),
            onPressed: () {
              // TODO: hook up filter options later
            },
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
                hintText: 'Search reports...',
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
            child: FutureBuilder<List<ReportListItem>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var reports = snapshot.data ?? [];
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
                      'No reports found',
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
                          onTap: () async {
                            final detail = await _repository.fetchReportDetail(
                              report.id,
                            );
                            if (detail == null || !context.mounted) return;

                            context
                                .read<FarmReportProvider>()
                                .loadReportForEditing(detail);

                            final batchId = detail['batch_id'] as String;

                            final batchRow = await Supabase.instance.client
                                .from('batches')
                                .select()
                                .eq('id', batchId)
                                .single();

                            if (!context.mounted) return;
                            context.read<FarmReportProvider>().setBatch(
                              ChickenBatch.fromJson(batchRow),
                            );

                            await context.push(
                              '/Farm_Report_Entry_Screen',
                              extra: batchId,
                            );

                            if (!context.mounted) return;
                            setState(() {
                              _reportsFuture = _loadReports();
                            });
                          },
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
            color: Colors.black.withOpacity(0.04),
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

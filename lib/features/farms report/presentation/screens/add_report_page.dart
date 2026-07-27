import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ikuku/features/batches/model/chicken_batch_model.dart';

import 'package:provider/provider.dart';

import 'package:ikuku/features/farms%20report/presentation/widgets/report_summary_card.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/features/farms%20report/repository/reports_repository.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  State<AddReportPage> createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final _repository = ReportsRepository();
  late Future<List<ReportSummary>> _recentReportsFuture;

  @override
  void initState() {
    super.initState();
    _recentReportsFuture = _loadReports();
  }

  Future<List<ReportSummary>> _loadReports() async {
    final rawReports = await _repository.fetchRecentReports();
    return rawReports.map(ReportSummary.fromJson).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(context),
        ),
        title: Text(
          'my_farms_report'.tr(),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: CustomColors.primary,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FeatureButton(
              label: 'add_farm_report'.tr(),
              onTap: () async {
                await context.push('/report-entry');
                if (!context.mounted) return;
                setState(() {
                  _recentReportsFuture = _loadReports();
                });
              },
              icon: Icons.add,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'previous_records'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: CustomColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/all_reports'),
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: Text(
                    'see_all_reports'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: CustomColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ReportSummary>>(
              future: _recentReportsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final reports = snapshot.data ?? [];
                if (reports.isEmpty) {
                  return Center(
                    child: Text(
                      'No reports yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return ReportSummaryCard(
                      report: report,
                      onTap: () async {
                        final detail = await _repository.fetchReportDetail(
                          report.id,
                        );
                        if (detail == null || !context.mounted) return;

                        context.read<FarmReportProvider>().loadReportForEditing(
                          detail,
                        );

                        final batchId = detail['batch_id'] as String;

                        // NEW: fetch the full batch and set the notifier, same as BatchSelectionPage does
                        final batchRow = await Supabase.instance.client
                            .from('batches')
                            .select()
                            .eq('id', batchId)
                            .single();

                        if (!context.mounted) return;
                        context.read<FarmReportProvider>().setBatch(
                          ChickenBatch.fromJson(batchRow),
                        );
                        if (!context.mounted) return;
                        await context.push(
                          '/Farm_Report_Entry_Screen',
                          extra: batchId,
                        );

                        if (!context.mounted) return;
                        setState(() {
                          _recentReportsFuture = _loadReports();
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

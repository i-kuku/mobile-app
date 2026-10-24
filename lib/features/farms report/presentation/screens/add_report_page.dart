import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/dashboard/presentation/components/app_bottom_nav_bar.dart';

import 'package:provider/provider.dart';

import 'package:ikuku/features/farms%20report/presentation/widgets/report_summary_card.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/features/farms%20report/repository/reports_repository.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  State<AddReportPage> createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final _repository = ReportsRepository();
  late List<ReportSummary> _recentReports;
  StreamSubscription<void>? _changes;

  @override
  void initState() {
    super.initState();
    _recentReports = _loadReports();
    _changes = _repository.changes.listen((_) => _reload());
    _repository.refresh();
  }

  @override
  void dispose() {
    _changes?.cancel();
    super.dispose();
  }

  List<ReportSummary> _loadReports() =>
      _repository.fetchRecentReports().map(ReportSummary.fromJson).toList();

  void _reload() {
    if (mounted) setState(() => _recentReports = _loadReports());
  }

  Future<void> _openReport(BuildContext context, ReportSummary report) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
                _reload();
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
            child: _recentReports.isEmpty
                ? Center(
                    child: Text(
                      'no_reports_yet'.tr(),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _recentReports.length,
                    itemBuilder: (context, index) {
                      final report = _recentReports[index];
                      return ReportSummaryCard(
                        report: report,
                        onTap: () => _openReport(context, report),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavbar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            context.go('/');
          } else if (index == 1) {
            context.go('/shop');
          } else if (index == 2) {
            context.go('/profile');
          }
        },
      ),
    );
  }
}

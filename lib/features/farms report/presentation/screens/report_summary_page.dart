import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/report_success_dialog.dart';
import 'package:ikuku/shared/widgets/loading_button.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/report_card_header.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class FarmReportEntryScreen extends StatelessWidget {
  final String batchId;
  const FarmReportEntryScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<FarmReportProvider>();
    final birdType = report.batch?.typeOfBird.toUpperCase() ?? '';
    final formattedDate = DateFormat('dd MMM yyyy').format(report.reportDate);

    return Scaffold(
      backgroundColor: const Color(0xfff7f9fa),
      appBar: AppBar(title: const Text('Farm Report Entry')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ReportHeaderCard(),
          const SizedBox(height: 16),
          _sectionCard(
            context,
            title: 'Birds- $birdType',
            rows: {
              'sold'.tr(): report.chickensSold,
              'died'.tr(): report.chickensDied,
              'curled'.tr(): report.chickensCurled,
              'stolen'.tr(): report.chickensStolen,
            },
            onEdit: () => context.push('/chicken_reduction'),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            context,
            title: 'eggs'.tr(),
            rows: {
              'collected'.tr(): report.eggsCollected,
              'broken'.tr(): report.eggsBroken,
              'big'.tr(): report.eggsStandard,
              'deformed'.tr(): report.eggsDeformed,
            },
            onEdit: () => context.push('/egg_production'),
          ),
          const SizedBox(height: 16),
          _listCard(
            context,
            title: 'feeds_used'.tr(),
            items: report.feedsUsed,
            onEdit: () => context.push('/feeds_selection'),
          ),
          const SizedBox(height: 16),
          _listCard(
            context,
            title: 'vaccines'.tr(),
            items: report.vaccinesUsed,
            onEdit: () => context.push('/vaccine_selection'),
          ),
          const SizedBox(height: 16),
          _listCard(
            context,
            title: 'other_materials'.tr(),
            items: report.otherMaterialsUsed,
            onEdit: () => context.push('/other_items_selection'),
          ),
          const SizedBox(height: 16),
          _notesCard(
            context,
            title: 'additional_notes'.tr(),
            notes: report.notes,
            onEdit: () => context.push('/additional_notes'),
          ),
          const SizedBox(height: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'this_report_was_prepared_on'.tr(),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                '$formattedDate'
                ' at ${DateFormat('HH:mm').format(DateTime.now())}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _finishButton(context, report),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _cardShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _cardHeader(String title, VoidCallback onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        InkWell(
          onTap: onEdit,
          child: Text(
            'edit_items'.tr(),
            style: TextStyle(
              color: CustomColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Map<String, int> rows,
    required VoidCallback onEdit,
  }) {
    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(title, onEdit),
          const SizedBox(height: 12),
          for (final entry in rows.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 16)),
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      color: CustomColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _listCard(
    BuildContext context, {
    required String title,
    required List<Map<String, dynamic>> items,
    required VoidCallback onEdit,
    Color? textColor,
  }) {
    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(title, onEdit),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final item in items)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item['name']}',
                    style: TextStyle(fontSize: 15, color: textColor),
                  ),
                  Text(
                    item['quantity'] != null ? '${item['quantity']}' : '',
                    style: TextStyle(fontSize: 15, color: textColor),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _notesCard(
    BuildContext context, {
    required String title,
    required String? notes,
    required VoidCallback onEdit,
  }) {
    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(title, onEdit),
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                notes,
                style: TextStyle(
                  color: CustomColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _finishButton(BuildContext context, FarmReportProvider report) {
    return LoadingButton(
      isLoading: report.isloading,
      onPressed: () async {
        final success = await context
            .read<FarmReportProvider>()
            .submitDailyReport(batchId: batchId);

        if (!context.mounted) return;

        if (success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return ReportSuccessDialog(
                onBackToDashboard: () {
                  
                  Navigator.pop(dialogContext);
                  context.go('/');
                },
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit report'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: const Text(
        'FINISH REPORTING',
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}

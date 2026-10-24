import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/batch_card.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/features/farms%20report/repository/reports_repository.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class BatchSelectionPage extends StatefulWidget {
  const BatchSelectionPage({super.key});

  @override
  State<BatchSelectionPage> createState() => _BatchSelectionPageState();
}

class _BatchSelectionPageState extends State<BatchSelectionPage> {
  final _repository = ReportsRepository();
  String? _selectedBatchId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BatchProvider>().fetchBatches();
    });
  }

  Color _getBirdTypeColor(String type) {
    switch (type.toLowerCase().trim()) {
      case 'broiler':
        return Colors.green.shade100;
      case 'layer':
        return Colors.grey.shade100;
      case 'kienyeji':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  void _alreadyReportedDialog(BuildContext context, String batchName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        title: Text('Report Already Submitted'),
        content: Text(
          "A daily report for this batch has already been submitted today",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Ok"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9fa),
      appBar: AppBar(
        leading: IconButton(
          color: CustomColors.primary,
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "farm_reports_entry".tr(),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 24,
            color: CustomColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                "select_batch_message".tr(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: CustomColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Consumer<BatchProvider>(
                  builder: (context, provider, _) {
                    if (provider.batches.isEmpty) {
                      return const Center(
                        child: Text('No active batches found.'),
                      );
                    }

                    final batches = provider.batches;
                    return ListView.builder(
                      itemCount: batches.length,
                      itemBuilder: (context, index) {
                        final batch = batches[index];
                        return BatchCard(
                          batch: batch,
                          onTap: () async {
                            if (_repository.hasReportOn(
                              batch.id,
                              DateTime.now(),
                            )) {
                              _alreadyReportedDialog(context, batch.name);
                              return;
                            }
                            setState(() {
                              _selectedBatchId = batch.id;
                            });
                            context.read<FarmReportProvider>().setBatch(batch);
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );

                            if (!context.mounted) return;

                            if (mounted) {
                              await context.push(
                                '/calendar_page',
                                extra: batch.id,
                              );
                            }
                          },
                          birdTypeColor: _getBirdTypeColor(batch.typeOfBird),
                          isSelected: _selectedBatchId == batch.id,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

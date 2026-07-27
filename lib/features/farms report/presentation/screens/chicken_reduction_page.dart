import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/batch_detail_container.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/reduction_reasons_checkboxes.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ChickenReductionPage extends StatefulWidget {
  final ChickenBatch? batch;

  const ChickenReductionPage({super.key, this.batch});

  @override
  State<ChickenReductionPage> createState() => _ChickenReductionPageState();
}

class _ChickenReductionPageState extends State<ChickenReductionPage> {
  String? _chickenReduction;
  double? _salesAmount;

  Map<String, int> _reductionCounts = {
    'curled': 0,
    'stolen': 0,
    'death': 0,
    'sold': 0,
  };
  @override
  void initState() {
    super.initState();
    final report = context.read<FarmReportProvider>();

    _reductionCounts = {
      'curled': report.chickensCurled,
      'stolen': report.chickensStolen,
      'death': report.chickensDied,
      'sold': report.chickensSold,
    };

    final hasReduction = _reductionCounts.values.any((v) => v > 0);
    _chickenReduction = hasReduction ? 'yes' : null;

    _salesAmount = report.salesAmount > 0
        ? report.salesAmount.toDouble()
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('farm_reports_entry'.tr())),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 24),
              Text(
                'chicken_reduction'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Batch Detail Container Card
              if (widget.batch != null)
                BatchDetailContainer(batch: widget.batch!),

              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'have_chickens_reduced_today'.tr(),
                    style: TextStyle(color: CustomColors.text, fontSize: 16),
                  ),

                  // Radio buttons hook directly into local state variables
                  Row(
                    children: [
                      RadioMenuButton<String>(
                        value: 'yes',
                        groupValue: _chickenReduction,
                        onChanged: (val) {
                          setState(() => _chickenReduction = val);
                        },
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(
                            CustomColors.primary,
                          ),
                        ),
                        child: Text('yes'.tr()),
                      ),
                      RadioMenuButton<String>(
                        value: 'no',
                        groupValue: _chickenReduction,
                        onChanged: (val) {
                          setState(() => _chickenReduction = val);
                        },
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(
                            CustomColors.primary,
                          ),
                        ),
                        child: Text('no'.tr()),
                      ),
                    ],
                  ),

                  if (_chickenReduction == 'yes') ...[
                    const SizedBox(height: 24),
                    Text(
                      'reduction_reason'.tr(),
                      style: TextStyle(color: CustomColors.text, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ReductionReasonCheckboxesMulti(
                      counts: _reductionCounts,
                      onCountsChanged: (newCounts) {
                        setState(() => _reductionCounts = newCounts);
                      },
                      salesAmount: _salesAmount,
                      onSalesAmountChanged: (amount) {
                        setState(() => _salesAmount = amount);
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ...inside build(), replace the FeatureButton's onTap:
                  FeatureButton(
                    label: "continue".tr(),
                    onTap: () {
                      final provider = context.read<FarmReportProvider>();
                      if (_chickenReduction == 'yes') {
                        provider.updateChicken(
                          curled: _reductionCounts['curled'],
                          sold: _reductionCounts['sold'],
                          died: _reductionCounts['death'],
                          stolen: _reductionCounts['stolen'],
                        );
                        if (_salesAmount != null) {
                          provider.updateFinancialsAndNotes(
                            sales: _salesAmount!.toInt(),
                          );
                        }
                      } else {
                        provider.updateChicken(
                          curled: 0,
                          sold: 0,
                          died: 0,
                          stolen: 0,
                        );
                      }
                      context.push('/egg_production');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

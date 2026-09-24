import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/features/financial%20summaries/presentation/widgets/drop_down.dart';
import 'package:ikuku/features/financial%20summaries/provider/financial_provider.dart';

class FinancialFiltersRow extends StatelessWidget {
  final FinancialSummaryProvider provider;
  final BatchProvider batchProvider;

  const FinancialFiltersRow({
    super.key,
    required this.provider,
    required this.batchProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Dropdown(
            child: DropdownButton<String>(
              value: provider.selectedBatchId,
              isExpanded: true,
              underline: SizedBox.shrink(),
              hint: Text("all_batches".tr()),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text("all_batches".tr()),
                ),
                ...batchProvider.batches.map(
                  (batch) => DropdownMenuItem<String>(
                    value: batch.id,
                    child: Text(batch.name),
                  ),
                ),
              ],
              onChanged: (value) => provider.setBatch(value),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Dropdown(
            child: DropdownButton<String>(
              value: provider.selectedTimeframe,
              isExpanded: true,
              underline: SizedBox.shrink(),
              items: [
                DropdownMenuItem(value: '3 months', child: Text('3 months'.tr())),
                DropdownMenuItem(value: 'LifeCycle', child: Text('LifeCycle'.tr())),
              ],
              onChanged: (value) {
                if (value != null) provider.setTimeframe(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/reducion_reasons_checkboxes.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';

class ChickenReductionPage extends StatefulWidget {
  final ChickenBatch? batch;
  
  const ChickenReductionPage({
    super.key,
    this.batch,
  });

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('chicken_reduction'.tr()),
    ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 24),
              Text(
                'chicken_reduction'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Batch Detail Container Card
              if (widget.batch != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade600, width: 1.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'selected_batch'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.batch!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.batch!.typeOfBird.toUpperCase()} • ${widget.batch!.initialCount} ${'birds'.tr()} • ${widget.batch!.age} ${widget.batch!.ageUnit} ${'old'.tr()}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
      
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
                          foregroundColor: WidgetStateProperty.all(CustomColors.primary),
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
                          foregroundColor: WidgetStateProperty.all(CustomColors.primary),
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
                  FeatureButton(
                    label: "continue".tr(),
                    onTap: () {
                      
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
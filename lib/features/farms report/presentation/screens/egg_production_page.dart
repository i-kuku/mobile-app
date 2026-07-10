import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/batch_detail_container.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/egg_collection_form.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';
// Import your newly separated form here

class EggProductionPage extends StatelessWidget {
  final ChickenBatch batch;

  const EggProductionPage({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CustomColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          "Farm_report_entry".tr(),
          style: TextStyle(
            color: CustomColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "egg_production".tr(),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.text,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Calling Your Component Widgets Cleanly here
                    BatchDetailContainer(batch: batch),
                    const EggCollectionForm(),
                  ],
                ),
              ),
            ),

            // Bottom Continue Action Button Layout
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: FeatureButton(
                label: "continue".tr(),
                onTap: () {
                  // Fixed the hyphen to an underscore here:
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

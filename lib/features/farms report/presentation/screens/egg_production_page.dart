import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/batch_detail_container.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/egg_collection_form.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';
// Import your newly separated form here

class EggProductionPage extends StatefulWidget {
  final ChickenBatch batch;


  const EggProductionPage({super.key, required this.batch});


  @override
  State<EggProductionPage> createState() => _EggProductionPageState();
}


class _EggProductionPageState extends State<EggProductionPage> {

  @override
void initState() {
  super.initState();
  // Fetch from Supabase right away when the app/section boots up
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<InventoryProvider>().fetchInventory();
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: CustomColors.primary),
          onPressed: () => context.pop(context),
        ),
        title:  Text(
          "farm_report_entry".tr(),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    BatchDetailContainer(batch: widget.batch),
                    const EggCollectionForm(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: FeatureButton(
                label: "continue".tr(),
                onTap: () {
                   
                  context.push('/feeds_selection', 
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

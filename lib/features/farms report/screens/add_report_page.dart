import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  State<AddReportPage> createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop(context);
          },
        ),
        title: Text(
          'my_farms_report'.tr(),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: CustomColors.primary,
            fontSize: 20,
          ),
        ),
      ),
      // adding button to add report
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FeatureButton(
              label: 'add_farm_report'.tr(),
              onTap: () {
                context.push('/add-report-form');
              },
              icon: Icons.add,
            ),
          ),
          SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'previous_records'.tr(),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: CustomColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.list_alt),
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
        ],
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/home/data/model/quick_action.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ADD THIS WHOLE FUNCTION, above the list:
Future<void> _handleFarmReportTap(BuildContext context) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  final batches = await Supabase.instance.client
      .from('batches')
      .select('id')
      .eq('user_id', userId)
      .limit(1);

  if (!context.mounted) return;

  if (batches.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quick Step Before\nAdding Report',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CustomColors.text,
                ),
              ),
              const SizedBox(height: 20),

              SvgPicture.asset('assets/images/farmer.svg', height: 140),
              const SizedBox(height: 20),
              Text(
                'It seems there are no chicken in your chick batch',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: CustomColors.buttonGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                      context.push('/batches'); // go add a batch
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'ADD CHICK BATCH',
                      style: TextStyle(
                        color: CustomColors.text,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return;
  }

  context.push('/reports');
}

List<QuickActionModel> quickActions = [
  QuickActionModel(
    label: 'add_chick_batch'.tr(),
    icon: SvgPicture.asset('assets/icons/add-batch.svg', width: 40, height: 40),
    route: '/batches',
    targetKey: batchesKey,
  ),
  QuickActionModel(
    label: 'farm_report'.tr(),
    icon: SvgPicture.asset('assets/icons/reportv3.svg', width: 40, height: 40),
    route: null,
    targetKey: reportsKey,
    onTap: _handleFarmReportTap,
  ),
  QuickActionModel(
    label: 'farm_store'.tr(),
    icon: SvgPicture.asset('assets/icons/storev2.svg', width: 40, height: 40),
    route: '/inventory',
    targetKey: storeKey,
  ),
  QuickActionModel(
    label: 'financial_summary'.tr(),
    icon: SvgPicture.asset('assets/icons/money.svg', width: 35, height: 35),
    route: '/farm-summary',
    targetKey: summaryKey,
  ),
  QuickActionModel(
    label: 'smart_tips'.tr(),
    icon: Icon(Icons.lightbulb, color: CustomColors.text, size: 36),
    route: '/smart-tips',
    targetKey: tipsKey,
  ),
  QuickActionModel(
    label: 'extension_service'.tr(),
    icon: SvgPicture.asset(
      'assets/icons/extensionv2.svg',
      width: 35,
      height: 35,
    ),
    route: null,
    targetKey: extensionKey,
  ),
];

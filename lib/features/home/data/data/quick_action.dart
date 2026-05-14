import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ikuku/features/home/data/model/quick_action.dart';
import 'package:ikuku/theme/app_theme.dart';

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
    route: '/reports',
    targetKey: reportsKey,
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

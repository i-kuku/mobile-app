import 'package:flutter/material.dart';

final GlobalKey batchesKey = GlobalKey();
final GlobalKey reportsKey = GlobalKey();
final GlobalKey storeKey = GlobalKey();
final GlobalKey tipsKey = GlobalKey();
final GlobalKey summaryKey = GlobalKey();
final GlobalKey extensionKey = GlobalKey();

class QuickActionModel {
  final String label;
  final Widget icon;
  final String? route;
  final GlobalKey? targetKey;

  QuickActionModel({
    required this.label,
    required this.icon,
    required this.route,
    required this.targetKey,
  });
}


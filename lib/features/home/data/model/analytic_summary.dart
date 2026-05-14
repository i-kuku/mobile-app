import 'package:easy_localization/easy_localization.dart';

class AnalyticSummary {
  final int totalBirds;
  final int totalFeeds;
  final int totalEggs;
  final String userName;

  AnalyticSummary({
    required this.totalBirds,
    required this.totalFeeds,
    required this.totalEggs,
    required this.userName,
  });

  factory AnalyticSummary.fromJson(Map<String,dynamic> json) {
    return AnalyticSummary(
      totalBirds: json['total_birds'] ?? 0,
      totalFeeds: json['total_feeds'] ?? 0,
      totalEggs: json['total_eggs'] ?? 0,
      userName: json['full_name'] ?? 'type_here'.tr(),
    );
  }
}

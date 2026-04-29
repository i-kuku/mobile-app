class AnalyticSummary {
  final int totalBirds;
  final int totalFeeds;
  final int totalEggs;

  AnalyticSummary({
    required this.totalBirds,
    required this.totalFeeds,
    required this.totalEggs,
  });

  factory AnalyticSummary.fromJson(Map json) {
    return AnalyticSummary(
      totalBirds: json['totalBirds'] ?? 0,
      totalFeeds: json['totalFeeds'] ?? 0,
      totalEggs: json['totalEggs'] ?? 0,
    );
  }
}

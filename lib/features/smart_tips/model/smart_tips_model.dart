class SmartTips{
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String? articleurl;

  SmartTips({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.articleurl,
  });
}
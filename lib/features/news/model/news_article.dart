class NewsArticle {
  final String title;
  final String description;
  final String link;
  final String source;
  final DateTime publishDate;
  final String? imageUrl;

  NewsArticle({
    required this.title,
    required this.description,
    required this.link,
    required this.source,
    required this.publishDate,
    this.imageUrl,
  });

  factory NewsArticle.fromRss(Map<String, dynamic> data) {
    final enclosure = data['enclosure'] as Map<String, dynamic>?;
    final imageUrl = enclosure != null && enclosure['url'] != null
        ? enclosure['url'] as String
        : null;

    return NewsArticle(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      link: data['link'] ?? '',
      source: data['source'] ?? 'Poultry News',
      publishDate: DateTime.tryParse(data['pubDate'] ?? '') ?? DateTime.now(),
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'link': link,
      'source': source,
      'publishDate': publishDate.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      source: json['source'] ?? 'Poultry News',
      publishDate:
          DateTime.tryParse(json['publishDate'] ?? '') ?? DateTime.now(),
      imageUrl: json['imageUrl'],
    );
  }
}
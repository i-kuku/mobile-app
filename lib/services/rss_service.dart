import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html_unescape/html_unescape.dart';

class NewsArticle {
  final String title;
  final String description;
  final DateTime publishDate;
  final String source;
  final String link;
  final String? imageUrl;

  NewsArticle({
    required this.title,
    required this.description,
    required this.publishDate,
    required this.source,
    required this.link,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'publishDate': publishDate.toIso8601String(),
    'source': source,
    'link': link,
    'imageUrl': imageUrl,
  };

  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
    title: json['title'],
    description: json['description'],
    publishDate: DateTime.parse(json['publishDate']),
    source: json['source'],
    link: json['link'],
    imageUrl: json['imageUrl'],
  );
}

class RssService {
  static const _cacheKey = 'cached_poultry_news';
  static const _maxCachedArticles = 20;

  final List<RssFeed> _feeds = [
    RssFeed(
      url: 'https://www.thepoultrysite.com/categories/africa/rss',
      name: 'The Poultry Site',
    ),
    RssFeed(
      url: 'https://farmersreviewafrica.com/category/poultry/feed',
      name: 'Farmers Review Africa',
    ),
    RssFeed(
      url:
          'https://allafrica.com/tools/headlines/rdf/sustainable/headlines.rdf',
      name: 'AllAfrica',
    ),
  ];

  Future<List<NewsArticle>> fetchLatestNews() async {
    List<NewsArticle> allArticles = [];

    for (final feed in _feeds) {
      try {
        final response = await http.get(Uri.parse(feed.url));
        if (response.statusCode == 200) {
          final document = XmlDocument.parse(response.body);
          final items = document.findAllElements('item');

          for (final item in items) {
            final title = _getElementText(item, 'title');
            if (!title.toLowerCase().contains('poultry') &&
                !title.toLowerCase().contains('chicken') &&
                !title.toLowerCase().contains('farm')) {
              continue;
            }

            final description = _cleanDescription(
              _getElementText(item, 'description'),
            );
            final pubDate = _parseDate(_getElementText(item, 'pubDate'));
            final link = _getElementText(item, 'link');
            String? imageUrl = _findImageUrl(item);

            allArticles.add(
              NewsArticle(
                title: title,
                description: description,
                publishDate: pubDate,
                source: feed.name,
                link: link,
                imageUrl: imageUrl,
              ),
            );
          }
        }
      } catch (e) {
        print('Error fetching from ${feed.name}: $e');
      }
    }

    // Sort by publication date, newest first
    allArticles.sort((a, b) => b.publishDate.compareTo(a.publishDate));

    // Cache the articles
    await _cacheArticles(allArticles);

    return allArticles;
  }

  String _getElementText(XmlElement item, String elementName) {
    final element = item.findElements(elementName).firstOrNull;
    return element?.innerText.trim() ?? '';
  }

  String _cleanDescription(String description) {
    // Remove HTML tags
    description = description.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode HTML entities
    description = HtmlUnescape().convert(description);
    // Limit to reasonable length
    if (description.length > 200) {
      description = '${description.substring(0, 197)}...';
    }
    return description.trim();
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        // Handle RFC822 format
        final regex = RegExp(
          r'^(?:(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun), )?(\d{1,2}) (?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d{4}) (\d{2}):(\d{2}):(\d{2})',
        );
        final match = regex.firstMatch(dateStr);
        if (match != null) {
          return DateTime.parse(match.group(0)!);
        }
      } catch (_) {}
      return DateTime.now();
    }
  }

  String? _findImageUrl(XmlElement item) {
    // Try media:content
    final mediaContent = item.findElements('media:content').firstOrNull;
    if (mediaContent != null) {
      return mediaContent.getAttribute('url');
    }

    // Try enclosure
    final enclosure = item.findElements('enclosure').firstOrNull;
    if (enclosure != null &&
        enclosure.getAttribute('type')?.startsWith('image/') == true) {
      return enclosure.getAttribute('url');
    }

    // Try looking in description for img tag
    final description = _getElementText(item, 'description');
    final imgMatch = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(description);
    return imgMatch?.group(1);
  }

  Future<void> _cacheArticles(List<NewsArticle> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final articlesToCache = articles.take(_maxCachedArticles).toList();
    final jsonList = articlesToCache.map((a) => a.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(jsonList));
  }

  Future<List<NewsArticle>> getCachedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => NewsArticle.fromJson(json)).toList();
    } catch (e) {
      print('Error reading cached articles: $e');
      return [];
    }
  }
}

class RssFeed {
  final String url;
  final String name;

  RssFeed({required this.url, required this.name});
}

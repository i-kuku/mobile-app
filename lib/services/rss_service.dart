import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
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

  /// How long one feed may take before it's given up on.
  static const feedTimeout = Duration(seconds: 15);

  /// The latest articles from every feed that answered. Saves them for
  /// offline use, unless no feed could be reached, so the saved ones aren't
  /// wiped while offline.
  Future<List<NewsArticle>> fetchLatestNews() async =>
      (await _fetchAll()).articles;

  /// The latest articles, or the ones saved last time when no feed can be
  /// reached, e.g. offline.
  Future<NewsFeed> loadNews() async {
    final (:articles, :reachedAnyFeed) = await _fetchAll();
    if (articles.isNotEmpty) return NewsFeed(articles, isSaved: false);
    // Nothing new came through, so show what was saved last time. It only
    // counts as offline if no feed could be reached at all.
    return NewsFeed(await getCachedArticles(), isSaved: !reachedAnyFeed);
  }

  Future<({List<NewsArticle> articles, bool reachedAnyFeed})>
  _fetchAll() async {
    // Fetched side by side so one slow feed doesn't hold up the others.
    final results = await Future.wait(_feeds.map(_fetchFeed));
    final reached = results.whereType<List<NewsArticle>>().toList();
    final allArticles = reached.expand((articles) => articles).toList();

    // Sort by publication date, newest first
    allArticles.sort((a, b) => b.publishDate.compareTo(a.publishDate));

    // Never replace the saved articles with nothing.
    if (allArticles.isNotEmpty) await _cacheArticles(allArticles);
    return (articles: allArticles, reachedAnyFeed: reached.isNotEmpty);
  }

  /// The poultry articles in [feed], or null if it couldn't be fetched.
  Future<List<NewsArticle>?> _fetchFeed(RssFeed feed) async {
    try {
      final response = await http.get(Uri.parse(feed.url)).timeout(feedTimeout);
      if (response.statusCode != 200) return null;

      final allArticles = <NewsArticle>[];
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
        // RSS 2.0 uses pubDate; RSS 1.0 (RDF) feeds use dc:date.
        final rawDate = _getElementText(item, 'pubDate');
        final pubDate = _parseDate(
          rawDate.isNotEmpty ? rawDate : _getElementText(item, 'dc:date'),
        );
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
      return allArticles;
    } catch (e) {
      debugPrint('Error fetching from ${feed.name}: $e');
      return null;
    }
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

  static const _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  // RFC822 named zones, as hours from UTC. Unknown names are treated as UTC.
  static const _zoneOffsets = {
    'EST': -5,
    'EDT': -4,
    'CST': -6,
    'CDT': -5,
    'MST': -7,
    'MDT': -6,
    'PST': -8,
    'PDT': -7,
  };

  static final _rfc822 = RegExp(
    r'^(?:[A-Za-z]{3},\s*)?(\d{1,2})\s+([A-Za-z]{3})\s+(\d{2,4})\s+'
    r'(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([+-]\d{4}|[A-Za-z]+)?',
  );

  DateTime _parseDate(String dateStr) {
    // ISO 8601, as used by Atom and RSS 1.0 (dc:date).
    final iso = DateTime.tryParse(dateStr);
    if (iso != null) return iso;

    // RFC822, as used by RSS 2.0 pubDate, e.g. "Tue, 10 Jun 2025 10:00:00 +0300".
    final match = _rfc822.firstMatch(dateStr.trim());
    final month = _months[match?.group(2)?.toLowerCase()];
    if (match == null || month == null) return DateTime.now();

    var year = int.parse(match.group(3)!);
    if (year < 100) year += 2000;

    final utc = DateTime.utc(
      year,
      month,
      int.parse(match.group(1)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6) ?? '0'),
    );
    return utc.subtract(_zoneOffset(match.group(7)));
  }

  Duration _zoneOffset(String? zone) {
    if (zone == null) return Duration.zero;
    if (zone.startsWith('+') || zone.startsWith('-')) {
      final sign = zone.startsWith('-') ? -1 : 1;
      final hours = int.parse(zone.substring(1, 3));
      final minutes = int.parse(zone.substring(3, 5));
      return Duration(minutes: sign * (hours * 60 + minutes));
    }
    return Duration(hours: _zoneOffsets[zone.toUpperCase()] ?? 0);
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
      debugPrint('Error reading cached articles: $e');
      return [];
    }
  }
}

class RssFeed {
  final String url;
  final String name;

  RssFeed({required this.url, required this.name});
}

/// Articles to show, and whether they are a saved copy from earlier.
class NewsFeed {
  const NewsFeed(this.articles, {required this.isSaved});

  final List<NewsArticle> articles;
  final bool isSaved;
}

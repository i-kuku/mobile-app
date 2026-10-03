import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ikuku/services/rss_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

String rss(String items) =>
    '<?xml version="1.0"?>'
    '<rss xmlns:media="http://search.yahoo.com/mrss/"><channel>$items</channel></rss>';

String rssItem({
  required String title,
  String description = '',
  String pubDate = '2025-01-01T00:00:00Z',
  String link = 'https://example.com',
  String extra = '',
}) =>
    '<item><title>$title</title>'
    '<description><![CDATA[$description]]></description>'
    '<pubDate>$pubDate</pubDate><link>$link</link>$extra</item>';

/// Runs [body] with every `http.get` answered by [feedBodies], keyed by host.
/// Feeds without an entry return 404.
Future<T> withFeeds<T>(
  Map<String, String> feedBodies,
  Future<T> Function() body,
) {
  final client = MockClient((request) async {
    final responseBody = feedBodies[request.url.host];
    return responseBody == null
        ? http.Response('not found', 404)
        : http.Response(responseBody, 200);
  });
  return http.runWithClient(body, () => client);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('fetchLatestNews', () {
    test('keeps only poultry/chicken/farm stories', () async {
      final articles = await withFeeds({
        'www.thepoultrysite.com': rss(
          rssItem(title: 'Poultry vaccine rollout') +
              rssItem(title: 'Chicken feed prices') +
              rssItem(title: 'New FARM subsidy') +
              rssItem(title: 'Football results'),
        ),
      }, () => RssService().fetchLatestNews());

      expect(
        articles.map((a) => a.title),
        unorderedEquals([
          'Poultry vaccine rollout',
          'Chicken feed prices',
          'New FARM subsidy',
        ]),
      );
      expect(articles.every((a) => a.source == 'The Poultry Site'), isTrue);
    });

    test('merges feeds and sorts newest first', () async {
      final articles = await withFeeds({
        'www.thepoultrysite.com': rss(
          rssItem(title: 'Old poultry', pubDate: '2024-01-01T00:00:00Z'),
        ),
        'farmersreviewafrica.com': rss(
          rssItem(title: 'New poultry', pubDate: '2025-06-01T00:00:00Z'),
        ),
        'allafrica.com': rss(
          rssItem(title: 'Mid poultry', pubDate: '2024-06-01T00:00:00Z'),
        ),
      }, () => RssService().fetchLatestNews());

      expect(articles.map((a) => a.title), [
        'New poultry',
        'Mid poultry',
        'Old poultry',
      ]);
      expect(articles.map((a) => a.source), [
        'Farmers Review Africa',
        'AllAfrica',
        'The Poultry Site',
      ]);
    });

    test('strips HTML, decodes entities and truncates descriptions', () async {
      final longText = 'a' * 250;
      final articles = await withFeeds({
        'www.thepoultrysite.com': rss(
          rssItem(
                title: 'Poultry short',
                pubDate: '2025-01-02T00:00:00Z',
                description: '<p>Eggs &amp; <b>chicks</b></p>',
              ) +
              rssItem(title: 'Poultry long', description: longText),
        ),
      }, () => RssService().fetchLatestNews());

      expect(articles[0].description, 'Eggs & chicks');
      expect(articles[1].description.length, 200);
      expect(articles[1].description, endsWith('...'));
    });

    test('finds images from media:content, enclosure and inline img', () async {
      final articles = await withFeeds({
        'www.thepoultrysite.com': rss(
          rssItem(
                title: 'Poultry media',
                pubDate: '2025-01-04T00:00:00Z',
                extra: '<media:content url="https://img/media.jpg"/>',
              ) +
              rssItem(
                title: 'Poultry enclosure',
                pubDate: '2025-01-03T00:00:00Z',
                extra:
                    '<enclosure url="https://img/enc.jpg" type="image/jpeg"/>',
              ) +
              rssItem(
                title: 'Poultry audio',
                pubDate: '2025-01-02T00:00:00Z',
                extra: '<enclosure url="https://img/a.mp3" type="audio/mpeg"/>',
              ) +
              rssItem(
                title: 'Poultry inline',
                pubDate: '2025-01-01T00:00:00Z',
                description: '<img src="https://img/inline.png"> text',
              ),
        ),
      }, () => RssService().fetchLatestNews());

      expect(articles.map((a) => a.imageUrl), [
        'https://img/media.jpg',
        'https://img/enc.jpg',
        null,
        'https://img/inline.png',
      ]);
    });

    test('skips failing or malformed feeds', () async {
      final articles = await withFeeds({
        'www.thepoultrysite.com': 'this is not xml <<<',
        'allafrica.com': rss(rssItem(title: 'Poultry ok')),
      }, () => RssService().fetchLatestNews());

      expect(articles.single.title, 'Poultry ok');
    });

    Future<DateTime> parsedDate(String pubDate) async {
      final articles = await withFeeds({
        'www.thepoultrysite.com': rss(
          rssItem(title: 'Poultry', pubDate: pubDate),
        ),
      }, () => RssService().fetchLatestNews());
      return articles.single.publishDate;
    }

    test('parses RFC822 dates with numeric offsets', () async {
      expect(
        await parsedDate('Tue, 10 Jun 2025 10:00:00 +0300'),
        DateTime.utc(2025, 6, 10, 7),
      );
      expect(
        await parsedDate('Tue, 10 Jun 2025 10:00:00 -0530'),
        DateTime.utc(2025, 6, 10, 15, 30),
      );
    });

    test('parses RFC822 dates with named zones', () async {
      expect(
        await parsedDate('Tue, 10 Jun 2025 10:00:00 GMT'),
        DateTime.utc(2025, 6, 10, 10),
      );
      expect(
        await parsedDate('Tue, 10 Jun 2025 10:00:00 EST'),
        DateTime.utc(2025, 6, 10, 15),
      );
    });

    test('parses RFC822 variants without weekday, seconds or zone', () async {
      expect(
        await parsedDate('5 Jan 2025 08:15'),
        DateTime.utc(2025, 1, 5, 8, 15),
      );
      expect(
        await parsedDate('Sun, 05 jan 25 08:15:30'),
        DateTime.utc(2025, 1, 5, 8, 15, 30),
      );
    });

    test('sorts RFC822 dates across feeds', () async {
      final articles = await withFeeds({
        'www.thepoultrysite.com': rss(
          rssItem(
                title: 'Older poultry',
                pubDate: 'Mon, 02 Jun 2025 09:00:00 GMT',
              ) +
              rssItem(
                title: 'Newer poultry',
                pubDate: 'Wed, 04 Jun 2025 09:00:00 GMT',
              ),
        ),
        'farmersreviewafrica.com': rss(
          rssItem(
            title: 'Middle poultry',
            pubDate: 'Tue, 03 Jun 2025 12:00:00 +0300',
          ),
        ),
      }, () => RssService().fetchLatestNews());

      expect(articles.map((a) => a.title), [
        'Newer poultry',
        'Middle poultry',
        'Older poultry',
      ]);
    });

    test('falls back to dc:date for RSS 1.0 feeds', () async {
      final articles = await withFeeds({
        'allafrica.com':
            '<?xml version="1.0"?>'
            '<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" '
            'xmlns:dc="http://purl.org/dc/elements/1.1/">'
            '<item><title>Poultry RDF</title>'
            '<dc:date>2025-06-10T10:00:00Z</dc:date></item></rdf:RDF>',
      }, () => RssService().fetchLatestNews());

      expect(articles.single.publishDate, DateTime.utc(2025, 6, 10, 10));
    });

    test('unparseable dates fall back to now', () async {
      final before = DateTime.now();
      final articles = await withFeeds({
        'www.thepoultrysite.com': rss(
          rssItem(title: 'Poultry', pubDate: 'Tue, 10 Foo 2025 10:00:00'),
        ),
      }, () => RssService().fetchLatestNews());

      expect(articles.single.publishDate.isBefore(before), isFalse);
    });
  });

  group('caching', () {
    test('returns an empty list when nothing is cached', () async {
      expect(await RssService().getCachedArticles(), isEmpty);
    });

    test('fetched articles are cached, capped at 20', () async {
      final items = List.generate(
        25,
        (i) => rssItem(
          title: 'Poultry $i',
          pubDate: DateTime.utc(2025, 1, 1 + i).toIso8601String(),
        ),
      ).join();
      final service = RssService();
      await withFeeds({
        'www.thepoultrysite.com': rss(items),
      }, service.fetchLatestNews);

      final cached = await service.getCachedArticles();
      expect(cached, hasLength(20));
      expect(cached.first.title, 'Poultry 24');
    });

    test('corrupt cache returns an empty list', () async {
      SharedPreferences.setMockInitialValues({
        'cached_poultry_news': 'not json',
      });
      expect(await RssService().getCachedArticles(), isEmpty);
    });

    test('reads a previously cached list', () async {
      SharedPreferences.setMockInitialValues({
        'cached_poultry_news': jsonEncode([
          {
            'title': 'Cached poultry',
            'description': 'd',
            'publishDate': '2025-02-02T00:00:00.000Z',
            'source': 'AllAfrica',
            'link': 'https://example.com',
            'imageUrl': 'https://img/x.png',
          },
        ]),
      });
      final cached = await RssService().getCachedArticles();
      expect(cached.single.title, 'Cached poultry');
      expect(cached.single.imageUrl, 'https://img/x.png');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/home/data/data/candidate_config.dart';
import 'package:ikuku/features/home/data/model/analytic_summary.dart';
import 'package:ikuku/features/settings/languages/model/language.dart';
import 'package:ikuku/services/rss_service.dart';

void main() {
  group('InventoryItem', () {
    final json = {
      'id': 'i1',
      'name': 'Layers mash',
      'category': 'feeds',
      'quantity': 12,
      'unit': 'Kg',
      'price': 150,
    };

    test('fromJson parses fields and converts int price to double', () {
      final item = InventoryItem.fromJson(json);
      expect(item.id, 'i1');
      expect(item.name, 'Layers mash');
      expect(item.category, 'feeds');
      expect(item.quantity, 12);
      expect(item.unit, 'Kg');
      expect(item.price, 150.0);
      expect(item.price, isA<double>());
    });

    test('fromJson defaults a missing price to 0', () {
      final item = InventoryItem.fromJson({...json}..remove('price'));
      expect(item.price, 0.0);
    });

    test('toJson round-trips', () {
      final item = InventoryItem.fromJson(json);
      expect(InventoryItem.fromJson(item.toJson()).toJson(), item.toJson());
      expect(item.toJson()['price'], 150.0);
    });
  });

  group('ChickenBatch', () {
    final json = {
      'id': 'b1',
      'name': 'Batch A',
      'type_of_bird': 'Kienyeji',
      'initial_count': 100,
      'age': 3,
      'age_unit': 'weeks',
      'created_at': '2025-01-15T08:30:00.000Z',
    };

    test('fromJson maps snake_case keys', () {
      final batch = ChickenBatch.fromJson(json);
      expect(batch.id, 'b1');
      expect(batch.name, 'Batch A');
      expect(batch.typeOfBird, 'Kienyeji');
      expect(batch.initialCount, 100);
      expect(batch.age, 3);
      expect(batch.ageUnit, 'weeks');
      expect(batch.createdAt, DateTime.utc(2025, 1, 15, 8, 30));
    });

    test('fromJson falls back to now when created_at is missing', () {
      final before = DateTime.now();
      final batch = ChickenBatch.fromJson({...json}..remove('created_at'));
      expect(batch.createdAt.isBefore(before), isFalse);
    });

    test('toJson round-trips', () {
      final batch = ChickenBatch.fromJson(json);
      final copy = ChickenBatch.fromJson(batch.toJson());
      expect(copy.toJson(), batch.toJson());
      expect(batch.toJson()['type_of_bird'], 'Kienyeji');
    });
  });

  group('AnalyticSummary', () {
    test('fromJson reads the dashboard stats', () {
      final summary = AnalyticSummary.fromJson({
        'total_birds': 250,
        'total_feeds': 40,
        'total_eggs': 900,
        'full_name': 'Jane Wanjiku',
      });
      expect(summary.totalBirds, 250);
      expect(summary.totalFeeds, 40);
      expect(summary.totalEggs, 900);
      expect(summary.userName, 'Jane Wanjiku');
    });

    test('fromJson defaults missing values', () {
      final summary = AnalyticSummary.fromJson({});
      expect(summary.totalBirds, 0);
      expect(summary.totalFeeds, 0);
      expect(summary.totalEggs, 0);
      // Falls back to the translation key when no localization is loaded.
      expect(summary.userName, 'type_here');
    });
  });

  group('NewsArticle', () {
    test('toJson/fromJson round-trips including a null image', () {
      final article = NewsArticle(
        title: 'Poultry prices rise',
        description: 'desc',
        publishDate: DateTime.utc(2025, 3, 1),
        source: 'The Poultry Site',
        link: 'https://example.com/a',
      );
      final copy = NewsArticle.fromJson(article.toJson());
      expect(copy.title, article.title);
      expect(copy.description, article.description);
      expect(copy.publishDate, article.publishDate);
      expect(copy.source, article.source);
      expect(copy.link, article.link);
      expect(copy.imageUrl, isNull);
    });
  });

  group('static config', () {
    test('supported languages are English and Swahili', () {
      expect(languages.map((l) => l.value), ['en', 'sw']);
      expect(languages.map((l) => l.label), ['english', 'swahili']);
    });

    test('tutorial candidate ids and keys are unique', () {
      final ids = candidateConfigs.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
      final keys = candidateConfigs.map((c) => c.key).toSet();
      expect(keys.length, candidateConfigs.length);
      for (final c in candidateConfigs) {
        expect(c.title, isNotEmpty);
        expect(c.message, isNotEmpty);
      }
    });
  });
}

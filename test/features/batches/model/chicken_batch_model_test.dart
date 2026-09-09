import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';

void main() {
  group('ChickenBatch', () {
    Map<String, dynamic> validJson({
      String id = 'batch001',
      String name = 'hilda',
      String ageUnit = 'weeks',
      String typeOfBird = 'layer',
      int initialCount = 100,
      int age = 100,
      dynamic purchaseCost = 300,
      String createdAt = '2025-01-01T00:00:00Z',
    }) {
      return {
        'id': id,
        'name': name,
        'age_unit': ageUnit,
        'type_of_bird': typeOfBird,
        'initial_count': initialCount,
        'age': age,
        'purchase_cost': purchaseCost,
        'created_at': createdAt,
      };
    }

    group('Constructor', () {
      test('Assigns all the values correctly', () {
        final createdAt = DateTime(2025, 01, 01);

        final batch = ChickenBatch(
          id: 'batch001',
          name: 'hilda',
          typeOfBird: 'layer',
          initialCount: 100,
          age: 100,
          ageUnit: 'weeks',
          createdAt: createdAt,
          purchaseCost: 300,
        );

        expect(batch.id, 'batch001');
        expect(batch.name, 'hilda');
        expect(batch.typeOfBird, 'layer');
        expect(batch.initialCount, 100);
        expect(batch.age, 100);
        expect(batch.ageUnit, 'weeks');
        expect(batch.purchaseCost, 300);
        expect(batch.createdAt, createdAt);
      });

      group('fromJson', () {
        test(' returns a valid Json map', () {
          final batch = ChickenBatch.fromJson(validJson());
          expect(batch.id, 'batch001');
          expect(batch.name, 'hilda');
          expect(batch.typeOfBird, 'layer');
          expect(batch.initialCount, 100);
          expect(batch.age, 100);
          expect(batch.ageUnit, 'weeks');
          expect(batch.purchaseCost, 300);
          expect(batch.createdAt, DateTime.parse('2025-01-01T00:00:00Z'));
        });

        test('parses purchase_cost correctly when it arrives as int', (){
          final batch = ChickenBatch.fromJson(validJson(purchaseCost: 100));
          expect(batch.purchaseCost, 100);
        });
         test('parses purchase_cost correctly when it arrives as double', (){
          final batch = ChickenBatch.fromJson(validJson(purchaseCost: 500.59));
          expect(batch.purchaseCost, 500.59);
        });
      });

      group('toJson', (){
        test('serializes all keys with the correct snake_case keys', (){
          final createdAt = DateTime.utc(2025,01,01,10,10);

          final batch = ChickenBatch(
            id: 'batch001' , 
            name: 'hilda', 
            typeOfBird: 'layer', 
            initialCount: 100, 
            age: 100, 
            ageUnit: 'weeks', 
            createdAt: createdAt, 
            purchaseCost: 300);

            final json = batch.toJson();

            expect(json['id'], 'batch001');
            expect(json['name'], 'hilda');
            expect(json['type_of_bird'], 'layer');
            expect(json['initial_count'], 100);
            expect(json['age'], 100);
            expect(json['age_unit'], 'weeks');
            expect(json['created_at'],createdAt.toIso8601String());
            expect(json['purchase_cost'], 300);
        });
      });
    });
  });
}

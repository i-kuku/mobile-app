import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';

void main() {
  group('ChickenBatch', () {
    Map<String, dynamic> validJson({
      String id = 'batch1',
      String name = 'Hilda',
      String typeOfBird = 'Broiler',
      int initialCount = 100,
      int age = 5,
      String ageUnit = 'days',
      String? createdAt = '2025-01-01T00:00:00Z',
      dynamic purchaseCost = 1500,
    }) {
      return {
        'id': id,
        'name': name,
        'type_of_bird': typeOfBird,
        'initial_count': initialCount,
        'age': age,
        'age_unit': ageUnit,
        'created_at': createdAt,
        'purchase_cost': purchaseCost,
      };
    }

    group('constructor', (){
     test('Assigns all fields correctly when provided', () {
       final createdAt = DateTime(2025, 1, 1);

       final batch = ChickenBatch(
        id: 'batch1', 
        name: 'Hilda', 
        typeOfBird: 'Broiler', 
        initialCount: 100, 
        age: 5, 
        ageUnit: 'days', 
        createdAt: createdAt,
        purchaseCost: 1500,        
       );

       expect(batch.id, 'batch1');
       expect(batch.name, 'Hilda');
       expect(batch.typeOfBird, 'Broiler');
       expect(batch.initialCount, 100);
       expect(batch.age, 5);
       expect(batch.ageUnit, 'days');
       expect(batch.createdAt, createdAt);
       expect(batch.purchaseCost, 1500);
     });
    });
    group('fromJson',(){
        test('fromJson returns a valid JSON map',(){
          final batch = ChickenBatch.fromJson(validJson());

          expect(batch.id, 'batch1');
          expect(batch.name, 'Hilda');
          expect(batch.typeOfBird, 'Broiler');
          expect(batch.initialCount, 100);
          expect(batch.age, 5);
          expect(batch.ageUnit, 'days');
          expect(batch.createdAt, DateTime.parse('2025-01-01T00:00:00Z'));
          expect(batch.purchaseCost, 1500);
        });

        test('parses purchase_cost when it arrives as int',(){
          final batch = ChickenBatch.fromJson(validJson(purchaseCost: 1000));

          expect(batch.purchaseCost, 1000);
        });
        test(' parses purchase_cost when it arrives a sdouble',(){
          final batch= ChickenBatch.fromJson(validJson(purchaseCost: 10.2));

          expect(batch.purchaseCost, 10.2);
        });
    });

    group('toJson',(){
      test('serializes all fields with the correct snake_case keys', (){
        final createdAt = DateTime.utc(2025,1,15,10,30);

        final batch = ChickenBatch(
          id: 'batch1', 
          name: 'Hilda', 
          typeOfBird: 'Broiler', 
          initialCount: 100, 
          age: 5, 
          ageUnit: 'days', 
          createdAt: createdAt, 
          purchaseCost: 1500
          );
        final json = batch.toJson();

        expect(json['id'], 'batch1');
        expect(json['name'], 'Hilda');
        expect(json['type_of_bird'], 'Broiler');
        expect(json['initial_count'], 100);
        expect(json['age'], 5);
        expect(json['age_unit'], 'days');
        expect(json['created_at'], createdAt.toIso8601String());
        expect(json['purchase_cost'], 1500);
      });
    });
  });
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/batches/presentation/Widgets/batch_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {};
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  ChickenBatch buildbatch({
    String id = 'batch1',
    String name = 'Hilda',
    String typeOfBird = 'Broiler',
    int initialCount = 100,
    int age = 5,
    String ageUnit = 'days',
    DateTime? createdAt,
    num purchaseCost = 1500,
  }) {
    return ChickenBatch(
      id: id,
      name: name,
      typeOfBird: typeOfBird,
      initialCount: initialCount,
      age: age,
      ageUnit: ageUnit,
      createdAt: createdAt ?? DateTime(2025, 1, 15),
      purchaseCost: purchaseCost,
    );
  }

  Widget buildTestable(Widget child) {
    return EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      assetLoader: _FakeAssetLoader(),
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }
  group('BatchCard',(){
    testWidgets('renders batch name,birdtype,count,age and unit', (tester) async{
      final batch = buildbatch(
         name: 'Hilda',
         typeOfBird: 'Broiler',
         initialCount: 100,
         age: 5,
         ageUnit: 'days',
      );
       
       await tester.pumpWidget(
        buildTestable(
          BatchCard(
            batch: batch,
            onEdit: (){},
            onDelete: (){},
          ),
        ),
       );
       await tester.pumpAndSettle();
       expect(find.text('Hilda'), findsOneWidget);
       expect(find.text('Bird type: Broiler'), findsOneWidget);
       expect(find.text('chicken: 100'), findsOneWidget);
       expect(find.text(', age: 5 days '), findsOneWidget);
    });
    testWidgets('renders Edit and Remove actions with their icons', (tester) async{
      await tester.pumpWidget(
         buildTestable(
          BatchCard(
            batch: buildbatch(),
            onEdit: (){},
            onDelete: (){},
          ),
         ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('tapping edit calls onEdit once and never onDelete', (tester) async{
        var editCount = 0;
        var deleteCount = 0;

        await tester.pumpWidget(
          buildTestable(
            BatchCard(
              batch: buildbatch(),
              onEdit: () => editCount++,
              onDelete: () => deleteCount++,
               ),
          )
        );

        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(InkWell, 'Edit'));
        await tester.pumpAndSettle();

        expect(editCount, 1);
        expect(deleteCount, 0);
    });

    testWidgets('tapping delete calls onDelete once and never onEdit', (tester) async{

       var editCount = 0;
       var deleteCount = 0;

       await tester.pumpWidget(
        buildTestable(
          BatchCard(
            batch: buildbatch() ,
            onEdit: () =>editCount++,
            onDelete: () => deleteCount++,
          ),
        )
       );
       await tester.pumpAndSettle();
       await tester.tap(find.widgetWithText(InkWell, 'Remove'));
       await tester.pumpAndSettle();

       expect(editCount, 0);
       expect(deleteCount, 1);
    });
  });
}



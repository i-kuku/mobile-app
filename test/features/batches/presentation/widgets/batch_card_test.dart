import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/batches/presentation/Widgets/batch_card.dart';

void main(){
   setUpAll(() async{
     TestWidgetsFlutterBinding.ensureInitialized();
     EasyLocalization.logger.enableLevels = [];
   });

// sample data to pass into the BatchCard
   final testBatch = ChickenBatch(
    id: 'batch_1', 
    name: 'Kienyeji Batch A', 
    typeOfBird: 'Kienyeji', 
    initialCount: 150, 
    age: 4, 
    ageUnit: 'weeks', 
    createdAt: DateTime.now());

Widget buildTestableWidget({
  required ChickenBatch batch,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}){
  return EasyLocalization(
    supportedLocales: const [Locale('en')], 
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    child: Builder(
      builder: (context){
        return MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: Scaffold(
            body: BatchCard(
              batch: batch, 
              onEdit: onEdit, 
              onDelete: onDelete,
              ),
          ),
        );
      } ,
      ), 
    );
}
 group('BatchCard Widget Tests', (){
    testWidgets('renders batch information correctly', (WidgetTester tester) async{
      // ACT
      await tester.pumpWidget(
        buildTestableWidget(
          batch: testBatch, 
          onEdit: (){}, 
          onDelete: (){}
          ),
      );
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Kienyeji Batch A'), findsOneWidget);
      expect(find.textContaining('Kienyeji'), findsOneWidget);
      expect(find.textContaining('150'),findsOneWidget);
      expect(find.textContaining('4 weeks'), findsOneWidget);
    });

    testWidgets('triggers onEdit callback when Edit button is tapped',(WidgetTester tester) async{
      bool editTapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          batch: testBatch, 
          onEdit: ()=> editTapped =  true, 
          onDelete: (){}
          ),
      );
     await tester.pumpAndSettle();
    //  Act: Find and tap the edit button
    final editButton = find.widgetWithText(InkWell, 'Edit'.tr());
    await tester.tap(editButton);
    await tester.pump();

    // Assert
    expect(editTapped, isTrue);
    });
  testWidgets('triggers onDelete callback when remove button is tapped', (WidgetTester tester) async{
    bool deleteTapped = false;

    await tester.pumpWidget(
      buildTestableWidget(
        batch: testBatch,
        onEdit: (){},
        onDelete: () => deleteTapped = true,
      ),
    );
    await tester.pumpAndSettle();

    // Act
    final removeButton = find.widgetWithText(InkWell, 'Remove'.tr());
    await tester.tap(removeButton);
    await tester.pump();

    // Assert
    expect(deleteTapped, isTrue);
  });
 });
}
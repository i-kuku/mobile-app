import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/Inventory/presentation/screens/inventory_hub_page.dart';
import 'package:ikuku/features/Inventory/presentation/widgets/add_item_dialog.dart';
import 'package:ikuku/features/Inventory/presentation/widgets/inventory_category_card.dart';
import 'package:ikuku/features/Inventory/presentation/widgets/inventory_item_card.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';
import 'package:ikuku/features/auth/presentation/components/auth_error_widget.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/batches/presentation/Widgets/batch_card.dart';
import 'package:ikuku/features/home/data/data/candidate_config.dart';
import 'package:ikuku/features/home/presentation/widgets/tutorial_card.dart';
import 'package:ikuku/features/home/provider/tutorial_provider.dart';
import 'package:ikuku/features/profile/presentation/widgets/menu_card.dart';
import 'package:ikuku/features/smart_tips/model/smart_tips_model.dart';
import 'package:ikuku/features/smart_tips/presentation/widgets/tip_card.dart';
import 'package:provider/provider.dart';

import '../helpers/test_app.dart';

void useViewport(WidgetTester tester, Size size) {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('AuthErrorWidget', () {
    testWidgets('renders nothing without an error', (tester) async {
      await tester.pumpWidget(
          wrap(AuthErrorWidget(errorMessage: null, internetTest: () {})));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('shows the error without a retry for other failures',
        (tester) async {
      await tester.pumpWidget(wrap(AuthErrorWidget(
          errorMessage: 'Invalid password', internetTest: () {})));
      expect(find.text('Invalid password'), findsOneWidget);
      expect(find.text('Test Connection'), findsNothing);
    });

    for (final message in ['No internet', 'Lost connection']) {
      testWidgets('offers a connection test for "$message"', (tester) async {
        var tested = false;
        await tester.pumpWidget(wrap(AuthErrorWidget(
            errorMessage: message, internetTest: () => tested = true)));
        await tester.tap(find.text('Test Connection'));
        expect(tested, isTrue);
      });
    }
  });

  group('BatchCard', () {
    final batch = ChickenBatch(
      id: 'b1',
      name: 'Batch A',
      typeOfBird: 'Layers',
      initialCount: 120,
      age: 4,
      ageUnit: 'weeks',
      createdAt: DateTime(2025),
    );

    testWidgets('shows batch details and wires up edit/remove',
        (tester) async {
      var edits = 0, deletes = 0;
      useViewport(tester, const Size(1600, 800));
      await tester.pumpWidget(wrap(ListView(children: [
        BatchCard(
          batch: batch,
          onEdit: () => edits++,
          onDelete: () => deletes++,
        ),
      ])));

      expect(find.text('Batch A'), findsOneWidget);
      expect(find.text('120 Layers'), findsOneWidget);
      expect(find.text('4 weeks old'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit));
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(edits, 1);
      expect(deletes, 1);
    });
  });

  group('TipCard', () {
    testWidgets('shows the tip and handles read more', (tester) async {
      var pressed = false;
      await tester.pumpWidget(wrap(TipCard(
        tip: SmartTips(
          id: '1',
          title: 'Keep water clean',
          description: 'Change water daily.',
          emoji: '💧',
        ),
        onReadMorePressed: () => pressed = true,
      )));

      expect(find.text('Keep water clean'), findsOneWidget);
      expect(find.text('Change water daily.'), findsOneWidget);
      expect(find.text('💧'), findsOneWidget);
      await tester.tap(find.text('read_more'));
      expect(pressed, isTrue);
    });
  });

  group('MenuCard', () {
    testWidgets('shows the title and handles taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(wrap(MenuCard(
        icon: Icons.logout,
        title: 'Log out',
        iconColor: Colors.red,
        onTap: () => taps++,
      )));
      expect(tester.widget<Icon>(find.byIcon(Icons.logout)).color, Colors.red);
      await tester.tap(find.text('Log out'));
      expect(taps, 1);
    });
  });

  group('InventoryCategoryCard', () {
    testWidgets('shows the category and handles taps', (tester) async {
      var taps = 0;
      // Mirror InventoryHubPage, which lays cards out in a full-width list.
      await tester.pumpWidget(wrap(ListView(children: [InventoryCategoryCard(
        category: InventoryCategory(
          name: 'Feeds',
          description: 'All feeds',
          icon: const Icon(Icons.grass),
          route: '/inventory/feedspage',
        ),
        onTap: () => taps++,
      )])));
      expect(find.text('Feeds'), findsOneWidget);
      expect(find.text('All feeds'), findsOneWidget);
      await tester.tap(find.text('Feeds'));
      expect(taps, 1);
    });
  });

  group('Inventory item flows', () {
    late InventoryProvider provider;
    final item = InventoryItem(
      id: 'i1',
      name: 'Layers mash',
      quantity: 5,
      unit: 'Kg',
      price: 150,
      category: 'feeds',
    );

    Widget app(Widget child) => ChangeNotifierProvider.value(
          value: provider,
          child: wrapWithRouter(child),
        );

    setUp(() {
      provider = InventoryProvider()..addInventoryItem(item);
    });

    testWidgets('card shows quantity and price', (tester) async {
      await tester.pumpWidget(app(InventoryItemCard(item: item)));
      expect(find.text('Layers mash'), findsOneWidget);
      expect(find.text('5 Kg'), findsOneWidget);
      expect(find.text('150.0 ksh'), findsOneWidget);
    });

    testWidgets('add dialog increments the stored quantity', (tester) async {
      await tester.pumpWidget(app(InventoryItemCard(item: item)));
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();
      expect(find.text('add Layers mash'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '3');
      await tester.tap(find.widgetWithText(ElevatedButton, 'add'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(provider.inventory.single.quantity, 8);
    });

    testWidgets('add dialog ignores invalid amounts', (tester) async {
      await tester.pumpWidget(app(InventoryItemCard(item: item)));
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      for (final input in ['abc', '0', '-2']) {
        await tester.enterText(find.byType(TextField), input);
        await tester.tap(find.widgetWithText(ElevatedButton, 'add'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget, reason: input);
      }
      expect(provider.inventory.single.quantity, 5);

      await tester.tap(find.text('cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('edit opens a prefilled form that updates the item',
        (tester) async {
      await tester.pumpWidget(app(InventoryItemCard(item: item)));
      await tester.tap(find.text('edit'));
      await tester.pumpAndSettle();

      expect(find.text('edit_feeds'), findsOneWidget);
      final fields = find.byType(TextFormField);
      expect(find.text('Layers mash'), findsNWidgets(2));
      await tester.enterText(fields.at(1), '20');
      await tester.tap(find.text('update'));
      await tester.pumpAndSettle();

      expect(find.byType(AddItemForm), findsNothing);
      expect(provider.inventory.single.quantity, 20);
      expect(provider.inventory.single.id, 'i1');
    });

    testWidgets('add form validates required fields then adds an item',
        (tester) async {
      // The dialog is 650px tall; give it room so every field is built.
      useViewport(tester, const Size(800, 1000));
      provider.clearInventory();
      await tester.pumpWidget(app(Builder(
        builder: (context) => TextButton(
          onPressed: () => addItemDialog(context, 'medicines'),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('add_medicines_to_store'), findsOneWidget);

      await tester.tap(find.text('add_item'));
      await tester.pump();
      expect(find.text('field_required'), findsNWidgets(3));
      expect(provider.inventory, isEmpty);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Newcastle vaccine');
      await tester.enterText(fields.at(1), '10');
      await tester.enterText(fields.at(2), '45.5');
      final unitDropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(unitDropdown);
      await tester.pumpAndSettle();
      await tester.tap(unitDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('L').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('add_item'));
      await tester.pumpAndSettle();

      final added = provider.inventory.single;
      expect(added.name, 'Newcastle vaccine');
      expect(added.quantity, 10);
      expect(added.price, 45.5);
      expect(added.unit, 'L');
      expect(added.category, 'medicines');
      expect(added.id, isNotEmpty);
    });
  });

  group('TutorialCard', () {
    testWidgets('shows progress and advances on continue', (tester) async {
      final provider = TutorialProvider();
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: provider,
        child: wrap(const TutorialCard(title: 'Batches', message: 'Tap here')),
      ));

      final total = candidateConfigs.length;
      expect(find.text('Step 1 of $total'), findsOneWidget);
      expect(find.text('Batches'), findsOneWidget);
      expect(find.text('Tap here'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Step 2 of $total'), findsOneWidget);

      // Skip with no active tour is a no-op.
      await tester.tap(find.text('Skip'));
      await tester.pump();
      expect(find.text('Step 2 of $total'), findsOneWidget);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';

InventoryItem item(String id, String category, {int quantity = 1}) =>
    InventoryItem(
      id: id,
      name: 'Item $id',
      quantity: quantity,
      unit: 'Kg',
      price: 10,
      category: category,
    );

void main() {
  late InventoryProvider provider;
  late int notifications;

  setUp(() {
    provider = InventoryProvider();
    notifications = 0;
    provider.addListener(() => notifications++);
  });

  test('starts empty and not loading', () {
    expect(provider.inventory, isEmpty);
    expect(provider.isloading, isFalse);
  });

  test('addInventoryItem adds and notifies', () {
    provider.addInventoryItem(item('1', 'feeds'));
    expect(provider.inventory.single.id, '1');
    expect(notifications, 1);
  });

  test('category getters filter by category', () {
    provider
      ..addInventoryItem(item('1', 'feeds'))
      ..addInventoryItem(item('2', 'medicines'))
      ..addInventoryItem(item('3', 'others'))
      ..addInventoryItem(item('4', 'feeds'));

    expect(provider.feeds.map((i) => i.id), ['1', '4']);
    expect(provider.medicines.map((i) => i.id), ['2']);
    expect(provider.others.map((i) => i.id), ['3']);
  });

  test('removeInventoryItem removes by id', () {
    provider
      ..addInventoryItem(item('1', 'feeds'))
      ..addInventoryItem(item('2', 'feeds'));
    provider.removeInventoryItem('1');
    expect(provider.inventory.map((i) => i.id), ['2']);
    expect(notifications, 3);
  });

  test('clearInventory empties the list', () {
    provider.addInventoryItem(item('1', 'feeds'));
    provider.clearInventory();
    expect(provider.inventory, isEmpty);
    expect(notifications, 2);
  });

  test('updateInventoryItem replaces a matching item', () {
    provider.addInventoryItem(item('1', 'feeds', quantity: 1));
    provider.updateInventoryItem(item('1', 'medicines', quantity: 9));
    expect(provider.inventory.single.quantity, 9);
    expect(provider.inventory.single.category, 'medicines');
    expect(notifications, 2);
  });

  test('updateInventoryItem ignores unknown ids without notifying', () {
    provider.addInventoryItem(item('1', 'feeds'));
    provider.updateInventoryItem(item('missing', 'feeds'));
    expect(provider.inventory.single.id, '1');
    expect(notifications, 1);
  });

  test('incrementQuantity adds to the existing quantity', () {
    provider.addInventoryItem(item('1', 'feeds', quantity: 5));
    provider.incrementQuantity('1', 3);
    final updated = provider.inventory.single;
    expect(updated.quantity, 8);
    expect(updated.name, 'Item 1');
    expect(updated.category, 'feeds');
    expect(notifications, 2);
  });

  test('incrementQuantity ignores unknown ids without notifying', () {
    provider.addInventoryItem(item('1', 'feeds', quantity: 5));
    provider.incrementQuantity('missing', 3);
    expect(provider.inventory.single.quantity, 5);
    expect(notifications, 1);
  });
}

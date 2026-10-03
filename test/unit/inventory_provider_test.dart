import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';

import '../helpers/fake_supabase.dart';

const inventoryPath = '/rest/v1/inventory_items';

InventoryItem item(String id, String category, {int quantity = 1}) =>
    InventoryItem(
      id: id,
      userId: fakeUserId,
      name: 'Item $id',
      quantity: quantity,
      unit: 'Kg',
      price: 10,
      category: category,
      addedOn: DateTime.utc(2025, 3, 1),
      dailyRecordsId: 'd$id',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final backend = FakeSupabaseBackend();

  setUpAll(() => initFakeSupabase(backend));
  tearDown(signOutFakeUser);

  late InventoryProvider provider;
  late int notifications;

  setUp(() async {
    backend.reset();
    backend.on('POST', inventoryPath, (_) async => http.Response('', 201));
    backend.on('PATCH', inventoryPath, (_) async => http.Response('', 204));
    backend.on('DELETE', inventoryPath, (_) async => http.Response('', 204));
    await signInFakeUser(backend);
    provider = InventoryProvider();
    notifications = 0;
    provider.addListener(() => notifications++);
  });

  test('starts empty and not loading', () {
    expect(provider.inventory, isEmpty);
    expect(provider.isloading, isFalse);
  });

  test('fetchInventory loads the user\'s items newest first', () async {
    backend.on(
      'GET',
      inventoryPath,
      (_) async => FakeSupabaseBackend.json([
        item('2', 'feeds').toJson(),
        item('1', 'medicines').toJson(),
      ]),
    );

    await provider.fetchInventory();

    expect(provider.inventory.map((i) => i.id), ['2', '1']);
    final query = backend.requestsTo(inventoryPath).single.url.queryParameters;
    expect(query['user_id'], 'eq.$fakeUserId');
    expect(query['order'], 'added_on.desc.nullslast');
    expect(provider.isloading, isFalse);
    expect(notifications, 2);
  });

  test('addInventoryItem inserts the row then adds it locally', () async {
    await provider.addInventoryItem(item('1', 'feeds'));

    final insert = backend.requestsTo(inventoryPath, method: 'POST').single;
    expect(jsonDecode(insert.body), item('1', 'feeds').toJson());
    expect(provider.inventory.single.id, '1');
    expect(notifications, 1);
  });

  test('addInventoryItem keeps local state when the server errors', () async {
    backend.on(
      'POST',
      inventoryPath,
      (_) async => FakeSupabaseBackend.json({'message': 'denied'}, status: 403),
    );

    await provider.addInventoryItem(item('1', 'feeds'));

    expect(provider.inventory, isEmpty);
    expect(notifications, 0);
  });

  test('category getters filter by category', () async {
    for (final i in [
      item('1', 'feeds'),
      item('2', 'medicines'),
      item('3', 'others'),
      item('4', 'feeds'),
    ]) {
      await provider.addInventoryItem(i);
    }

    expect(provider.feeds.map((i) => i.id), ['1', '4']);
    expect(provider.medicines.map((i) => i.id), ['2']);
    expect(provider.others.map((i) => i.id), ['3']);
  });

  test('deleteInventoryItem deletes the row and drops it locally', () async {
    await provider.addInventoryItem(item('1', 'feeds'));
    await provider.addInventoryItem(item('2', 'feeds'));

    await provider.deleteInventoryItem('1');

    final delete = backend.requestsTo(inventoryPath, method: 'DELETE').single;
    expect(delete.url.queryParameters['id'], 'eq.1');
    expect(provider.inventory.map((i) => i.id), ['2']);
    expect(notifications, 3);
  });

  test('incrementQuantity patches the new total', () async {
    await provider.addInventoryItem(item('1', 'feeds', quantity: 5));

    await provider.incrementQuantity('1', 3);

    final patch = backend.requestsTo(inventoryPath, method: 'PATCH').single;
    expect(patch.url.queryParameters['id'], 'eq.1');
    expect(jsonDecode(patch.body), {'quantity': 8});
    expect(provider.inventory.single.quantity, 8);
    expect(provider.inventory.single.dailyRecordsId, 'd1');
  });

  test('incrementQuantity ignores unknown ids', () async {
    await provider.incrementQuantity('missing', 3);
    expect(backend.requestsTo(inventoryPath), isEmpty);
    expect(notifications, 0);
  });

  test('updateInventoryItem patches the row and replaces it locally', () async {
    await provider.addInventoryItem(item('1', 'feeds'));

    await provider.updateInventoryItem(item('1', 'feeds', quantity: 20));

    final patch = backend.requestsTo(inventoryPath, method: 'PATCH').single;
    expect(patch.url.queryParameters['id'], 'eq.1');
    expect(jsonDecode(patch.body)['quantity'], 20);
    expect(provider.inventory.single.quantity, 20);
  });

  test('clearInventory empties the list', () async {
    await provider.addInventoryItem(item('1', 'feeds'));
    provider.clearInventory();
    expect(provider.inventory, isEmpty);
  });
}

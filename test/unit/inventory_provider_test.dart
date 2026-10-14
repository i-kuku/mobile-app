import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

import '../helpers/fake_supabase.dart';

const inventoryPath = '/rest/v1/inventory_items';

InventoryItem item(
  String id,
  String category, {
  int quantity = 1,
  DateTime? addedOn,
}) => InventoryItem(
  id: id,
  userId: fakeUserId,
  name: 'Item $id',
  quantity: quantity,
  unit: 'Kg',
  price: 10,
  category: category,
  addedOn: addedOn ?? DateTime.utc(2025, 3, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final backend = FakeSupabaseBackend();

  setUpAll(() => initFakeSupabase(backend));

  late SyncEngine sync;
  late InventoryProvider provider;
  late int notifications;

  setUp(() async {
    backend.reset();
    backend.on('POST', inventoryPath, (_) async => http.Response('', 201));
    backend.on('PATCH', inventoryPath, (_) async => http.Response('', 204));
    backend.on('DELETE', inventoryPath, (_) async => http.Response('', 204));
    sync = (await initOfflineServices()).sync;
    await signInFakeUser(backend);
    provider = InventoryProvider();
    notifications = 0;
    provider.addListener(() => notifications++);
  });

  tearDown(() async {
    provider.dispose();
    await resetOfflineServices();
    await signOutFakeUser();
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
        item('1', 'medicines', addedOn: DateTime.utc(2025, 1, 1)).toJson(),
        item('2', 'feeds', addedOn: DateTime.utc(2025, 2, 1)).toJson(),
      ]),
    );

    await provider.fetchInventory();

    expect(provider.inventory.map((i) => i.id), ['2', '1']);
    final query = backend.requestsTo(inventoryPath).single.url.queryParameters;
    expect(query['user_id'], 'eq.$fakeUserId');
    expect(provider.isloading, isFalse);
  });

  test('a first load waits for the server, showing a spinner', () async {
    backend.on(
      'GET',
      inventoryPath,
      (_) async => FakeSupabaseBackend.json([item('1', 'feeds').toJson()]),
    );
    final loading = <bool>[];
    provider.addListener(() => loading.add(provider.isloading));

    await provider.fetchInventory();

    // The device's (empty) copy shows first, then the spinner, then data.
    expect(loading, contains(true));
    expect(loading.last, isFalse);
    expect(provider.inventory.single.id, '1');
  });

  test('offline, it shows the device\'s copy without a spinner', () async {
    await sync.store.put(
      LocalTables.inventoryItems,
      item('1', 'feeds').toJson(),
    );
    sync.connectivity.reportUnreachable();
    backend.on('GET', '/rest/v1/users', unreachable);
    final loading = <bool>[];
    provider.addListener(() => loading.add(provider.isloading));

    await provider.fetchInventory();

    expect(provider.inventory.single.id, '1');
    expect(loading, everyElement(isFalse));
  });

  test('addInventoryItem adds it locally, then inserts the row', () async {
    await provider.addInventoryItem(item('1', 'feeds'));

    expect(provider.inventory.single.id, '1');
    expect(notifications, 1);

    await sync.sync(pull: false);
    final insert = backend.requestsTo(inventoryPath, method: 'POST').single;
    expect(jsonDecode(insert.body), item('1', 'feeds').toJson());
  });

  test('addInventoryItem keeps the item when the server refuses it', () async {
    backend.on(
      'POST',
      inventoryPath,
      (_) async => FakeSupabaseBackend.json({'message': 'denied'}, status: 403),
    );

    await provider.addInventoryItem(item('1', 'feeds'));
    await sync.sync(pull: false);

    expect(provider.inventory.single.id, '1');
    expect(sync.pendingCount, 1);
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

    expect(provider.feeds.map((i) => i.id), unorderedEquals(['1', '4']));
    expect(provider.medicines.map((i) => i.id), ['2']);
    expect(provider.others.map((i) => i.id), ['3']);
  });

  test('deleteInventoryItem drops it locally, then deletes the row', () async {
    await provider.addInventoryItem(item('1', 'feeds'));
    await provider.addInventoryItem(item('2', 'feeds'));

    await provider.deleteInventoryItem('1');

    expect(provider.inventory.map((i) => i.id), ['2']);
    await sync.sync(pull: false);
    final delete = backend.requestsTo(inventoryPath, method: 'DELETE').single;
    expect(delete.url.queryParameters['id'], 'eq.1');
  });

  test('incrementQuantity patches the new total', () async {
    await provider.addInventoryItem(item('1', 'feeds', quantity: 5));

    await provider.incrementQuantity('1', 3);

    expect(provider.inventory.single.quantity, 8);
    await sync.sync(pull: false);
    final patch = backend.requestsTo(inventoryPath, method: 'PATCH').single;
    expect(patch.url.queryParameters['id'], 'eq.1');
    expect(jsonDecode(patch.body), {'quantity': 8});
  });

  test('incrementQuantity ignores unknown ids', () async {
    await provider.incrementQuantity('missing', 3);
    expect(sync.pendingCount, 0);
    expect(notifications, 0);
  });

  test(
    'updateInventoryItem replaces it locally, then patches the row',
    () async {
      await provider.addInventoryItem(item('1', 'feeds'));

      await provider.updateInventoryItem(item('1', 'feeds', quantity: 20));

      expect(provider.inventory.single.quantity, 20);
      await sync.sync(pull: false);
      final patch = backend.requestsTo(inventoryPath, method: 'PATCH').single;
      expect(patch.url.queryParameters['id'], 'eq.1');
      expect(jsonDecode(patch.body)['quantity'], 20);
    },
  );

  test('clearInventory empties the list', () async {
    await provider.addInventoryItem(item('1', 'feeds'));
    provider.clearInventory();
    expect(provider.inventory, isEmpty);
  });
}

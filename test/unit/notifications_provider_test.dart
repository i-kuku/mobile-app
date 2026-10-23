import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/notifications/provider/notifications_provider.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

import '../helpers/fake_supabase.dart';

const notificationsPath = '/rest/v1/user_notifications';

Map<String, dynamic> serverNotification(
  String id,
  String key, {
  String createdAt = '2026-01-01T00:00:00Z',
  String? titleSw = 'T',
}) => {
  'id': id,
  'user_id': fakeUserId,
  'type': 'prediction',
  'reference_key': key,
  'title_en': 'T',
  'title_sw': titleSw,
  'message_en': 'M',
  'message_sw': 'M',
  'is_read': false,
  'created_at': createdAt,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final backend = FakeSupabaseBackend();
  late SyncEngine sync;
  late NotificationsProvider provider;

  final feed = InventoryItem(
    id: 'f1',
    userId: fakeUserId,
    name: 'Mash',
    quantity: 5,
    unit: 'Kg',
    price: 1,
    category: 'feeds',
    addedOn: DateTime.utc(2025),
  );
  // Old enough for its vaccination reminder to be due.
  final batch = ChickenBatch(
    id: 'b1',
    name: 'Layers',
    typeOfBird: 'layer',
    initialCount: 10,
    age: 1,
    ageUnit: 'Days',
    createdAt: DateTime.utc(2025, 1, 1),
    purchaseCost: 0,
  );
  final today = DateTime.now().toIso8601String().split('T')[0];

  setUpAll(() => initFakeSupabase(backend));

  setUp(() async {
    backend.reset();
    sync = (await initOfflineServices(
      pullSpecs: [
        defaultPullSpecs.firstWhere(
          (spec) => spec.table == LocalTables.userNotifications,
        ),
      ],
    )).sync;
    // The fake account dates from 2025, so the prediction is due too.
    await signInFakeUser(backend);
    provider = NotificationsProvider();
  });

  tearDown(() async {
    provider.dispose();
    await resetOfflineServices();
    await signOutFakeUser();
  });

  void serverHas(List<Map<String, dynamic>> rows) => backend.on(
    'GET',
    notificationsPath,
    // Honour `limit` the way PostgREST would.
    (request) async {
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '');
      return FakeSupabaseBackend.json(
        limit == null ? rows : rows.take(limit).toList(),
      );
    },
  );

  Future<void> generate() => provider.fetchNotifications(
    lowStockFeeds: [feed],
    hasRecordedToday: false,
    batches: [batch],
  );

  List<String> keys() => [
    for (final row in sync.store.rows(LocalTables.userNotifications))
      row['reference_key'] as String,
  ];

  test('makes nothing until the server copy has been fetched once', () async {
    backend.on('GET', notificationsPath, unreachable);

    await generate();

    expect(keys(), isEmpty);
    expect(sync.pendingCount, 0);
  });

  test('makes the due notifications, skipping ones the server has', () async {
    serverHas([serverNotification('s1', 'prediction_ready')]);

    await generate();

    expect(
      keys(),
      unorderedEquals([
        'prediction_ready',
        'low_stock_f1_$today',
        'missing_record_$today',
        'vaccine_reminder_b1',
      ]),
    );
    expect(sync.pendingCount, 3);
    expect(provider.notifications, hasLength(4));
  });

  test('running again the same day makes nothing new', () async {
    serverHas([]);

    await generate();
    await generate();

    expect(sync.pendingCount, 4);
  });

  test('still knows about older notifications past the newest 50', () async {
    serverHas([
      for (var i = 0; i < 60; i++)
        serverNotification(
          's$i',
          'low_stock_x_$i',
          createdAt: DateTime.utc(
            2026,
            3,
            1,
          ).add(Duration(days: i)).toIso8601String(),
        ),
      serverNotification(
        'old',
        'prediction_ready',
        createdAt: '2025-02-01T00:00:00Z',
      ),
    ]);

    await generate();

    expect(keys().where((key) => key == 'prediction_ready'), hasLength(1));
  });

  test('drops notifications the server already has under another id', () async {
    serverHas([]);
    backend.on(
      'POST',
      notificationsPath,
      (_) async => FakeSupabaseBackend.json({
        'code': '23505',
        'message': 'duplicate key value violates unique constraint',
      }, status: 409),
    );
    await generate();

    await sync.sync(pull: false);

    expect(sync.pendingCount, 0);
    expect(sync.parkedCount, 0);
    expect(keys(), isEmpty);
  });

  test('skips rows it cannot read', () async {
    serverHas([
      serverNotification('good', 'a'),
      serverNotification('bad', 'b', titleSw: null),
    ]);

    await sync.sync();

    expect(provider.notifications.map((n) => n.id), ['good']);
  });

  test('clears the list when the user signs out', () async {
    serverHas([serverNotification('s1', 'a')]);
    await sync.sync();
    expect(provider.notifications, hasLength(1));

    await signOutFakeUser();
    await OfflineServices.instance.signedOut();

    expect(provider.notifications, isEmpty);
  });

  test('markAsRead marks it on the phone and queues the update', () async {
    serverHas([serverNotification('s1', 'a')]);
    await sync.sync();

    await provider.markAsRead('s1');

    expect(provider.notifications.single.isRead, isTrue);
    final change = sync.outbox.pending.single;
    expect(change.kind, ChangeKind.update);
    expect(change.payload, {'is_read': true});
    expect(change.match, {'id': 's1'});
  });
}

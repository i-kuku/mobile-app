import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/shared/offline/local_store.dart';
import 'package:ikuku/shared/offline/outbox.dart';

class _BrokenPersistence extends MemoryStorePersistence {
  @override
  Future<Map<String, String>> load(String table) async =>
      table == LocalTables.batches
      ? throw const FormatException('corrupt box')
      : super.load(table);

  @override
  Future<void> put(String table, Map<String, String> rows) async =>
      throw const FormatException('disk full');
}

void main() {
  late MemoryStorePersistence disk;
  late LocalStore store;

  setUp(() async {
    disk = MemoryStorePersistence();
    store = await LocalStore.open(disk);
  });

  test('stores rows by id and reads them back', () async {
    await store.put('batches', {'id': 'b1', 'name': 'A'});
    await store.put('batches', {'id': 'b2', 'name': 'B'});
    await store.put('batches', {'id': 'b1', 'name': 'A2'});

    expect(store.rows('batches').map((r) => r['name']), ['A2', 'B']);
    expect(store.row('batches', 'b2'), {'id': 'b2', 'name': 'B'});
    expect(store.row('batches', 'missing'), isNull);
    expect(store.contains('batches', 'b1'), isTrue);
  });

  test('keys numeric ids as strings', () async {
    await store.put('sale', {'id': 7, 'amount': 10});
    expect(store.row('sale', '7')?['amount'], 10);
  });

  test('rejects rows without an id', () {
    expect(() => store.put('batches', {'name': 'x'}), throwsArgumentError);
  });

  test('hands out copies, so callers cannot change stored rows', () async {
    await store.put('batch_records', {
      'id': 'r1',
      'feeds_used': [
        {'name': 'Mash'},
      ],
    });
    final row = store.row('batch_records', 'r1')!;
    (row['feeds_used'] as List).clear();
    row['id'] = 'changed';

    expect(store.row('batch_records', 'r1')!['feeds_used'], hasLength(1));
  });

  test('announces the table on every change', () async {
    final changed = <String>[];
    store.changes.listen(changed.add);

    await store.put('batches', {'id': 'b1'});
    await store.remove('batches', 'b1');
    await store.remove('batches', 'b1');
    await store.replaceAll('farms', [
      {'id': 'f1'},
    ]);
    await store.replaceAll('farms', [
      {'id': 'f1'},
    ]);

    expect(changed, ['batches', 'batches', 'farms']);
  });

  test('replaceAll leaves exactly the given rows', () async {
    await store.putAll('batches', [
      {'id': 'a'},
      {'id': 'b'},
    ]);
    await store.replaceAll('batches', [
      {'id': 'b', 'v': 2},
      {'id': 'c'},
    ]);

    expect(store.rows('batches'), [
      {'id': 'b', 'v': 2},
      {'id': 'c'},
    ]);
    expect(disk.tables['batches']!.keys, unorderedEquals(['b', 'c']));
  });

  test('survives a restart', () async {
    await store.put('batches', {'id': 'b1', 'name': 'A'});
    await store.putCached('summary', {'total': 3});

    final reopened = await LocalStore.open(disk);

    expect(reopened.row('batches', 'b1'), {'id': 'b1', 'name': 'A'});
    expect(reopened.cached('summary')?.value, {'total': 3});
    expect(reopened.cached('summary')?.savedAt, isNotNull);
  });

  test('starts with an empty table when one cannot be read', () async {
    final broken = await LocalStore.open(_BrokenPersistence());
    expect(broken.rows('batches'), isEmpty);
  });

  test('keeps working in memory when the disk refuses a write', () async {
    final broken = await LocalStore.open(_BrokenPersistence());
    await broken.put('farms', {'id': 'f1'});
    expect(broken.row('farms', 'f1'), {'id': 'f1'});
  });

  group('claimFor', () {
    test('keeps the data of the same user', () async {
      await store.claimFor('u1');
      await store.put('batches', {'id': 'b1'});

      await store.claimFor('u1');

      expect(store.rows('batches'), hasLength(1));
      expect(store.ownerId, 'u1');
    });

    test('clears another user\'s data, outbox included', () async {
      await store.claimFor('u1');
      await store.put('batches', {'id': 'b1'});
      await Outbox(store).add(kind: ChangeKind.upsert, target: 'batches');

      await store.claimFor('u2');

      expect(store.rows('batches'), isEmpty);
      expect(Outbox(store).isEmpty, isTrue);
      expect(store.ownerId, 'u2');
    });
  });

  test('clear empties every table and the disk', () async {
    await store.put('batches', {'id': 'b1'});
    await store.put('sale', {'id': 's1'});

    await store.clear();

    expect(store.rows('batches'), isEmpty);
    expect(store.rows('sale'), isEmpty);
    expect(disk.tables['batches'], isNull);
  });
}

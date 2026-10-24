import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/shared/offline/local_store.dart';
import 'package:ikuku/shared/offline/outbox.dart';

void main() {
  late MemoryStorePersistence disk;
  late Outbox outbox;

  setUp(() async {
    disk = MemoryStorePersistence();
    outbox = Outbox(await LocalStore.open(disk));
  });

  test('keeps changes in the order they were made', () async {
    for (var i = 0; i < 12; i++) {
      await outbox.add(
        kind: ChangeKind.upsert,
        target: 'batches',
        recordId: 'b$i',
      );
    }
    expect(outbox.pending.map((c) => c.recordId), [
      for (var i = 0; i < 12; i++) 'b$i',
    ]);
  });

  test('survives a restart, order and details intact', () async {
    await outbox.add(
      kind: ChangeKind.update,
      target: 'farms',
      recordId: 'f1',
      payload: {'farm_location': 'Nakuru'},
      match: {'user_id': 'u1'},
    );
    await outbox.add(kind: ChangeKind.rpc, target: 'do_thing');

    final reopened = Outbox(await LocalStore.open(disk));
    final [first, second] = reopened.pending;

    expect(first.kind, ChangeKind.update);
    expect(first.target, 'farms');
    expect(first.payload, {'farm_location': 'Nakuru'});
    expect(first.match, {'user_id': 'u1'});
    expect(second.kind, ChangeKind.rpc);
    expect(second.seq, greaterThan(first.seq));
  });

  test('continues numbering after the newest change', () async {
    final first = await outbox.add(kind: ChangeKind.rpc, target: 'a');
    final second = await outbox.add(kind: ChangeKind.rpc, target: 'b');
    await outbox.remove(first);
    final third = await outbox.add(kind: ChangeKind.rpc, target: 'c');

    expect(third.seq, second.seq + 1);
  });

  test('separates parked changes from pending ones', () async {
    final change = await outbox.add(kind: ChangeKind.rpc, target: 'a');
    await outbox.add(kind: ChangeKind.rpc, target: 'b');

    await outbox.update(change.copyWith(attempts: 5, parked: true));

    expect(outbox.pending.map((c) => c.target), ['b']);
    expect(outbox.parked.single.attempts, 5);
    expect(outbox.all, hasLength(2));
  });

  test('reports which rows have changes on their way', () async {
    await outbox.add(kind: ChangeKind.upsert, target: 'batches', recordId: 'a');
    await outbox.add(kind: ChangeKind.delete, target: 'batches', recordId: 'b');
    await outbox.add(kind: ChangeKind.upsert, target: 'farms', recordId: 'c');

    expect(outbox.touchedIds('batches'), {'a', 'b'});
    expect(outbox.deletedIds('batches'), {'b'});
    expect(outbox.touches('farms', 'c'), isTrue);
    expect(outbox.touches('batches', 'c'), isFalse);
  });
}

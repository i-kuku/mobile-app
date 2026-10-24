import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late SyncEngine sync;
  late BatchProvider batchProvider;

  setUp(() async {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    sync = SyncEngine(
      store: await LocalStore.inMemory(),
      connectivity: ConnectivityService.fixed(),
      client: () => mockSupabase,
    );
    batchProvider = BatchProvider(sync: sync);
  });

  tearDown(() => sync.dispose());

  group('Batch provider - Auth & Guard checks', () {
    test('fetchBatches does nothing if currentUser is null', () async {
      //  arrange:simulates unauthenticated user
      when(() => mockAuth.currentUser).thenReturn(null);
      // Act
      await batchProvider.fetchBatches();
      // assert: List remains empty and no databas queries were executed
      expect(batchProvider.batches, isEmpty);
      verifyNever(() => mockSupabase.from(any()));
    });

    test('addBatch returns exception when user is not authenticated', () {
      // arrange
      when(() => mockAuth.currentUser).thenReturn(null);
      // act &Assert
      expect(
        () => batchProvider.addBatch(
          name: 'Batch A',
          typeOfBird: 'broiler',
          initialCount: 50,
          age: 3,
          ageUnit: 'weeks',
          purchaseCost: 200,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('BatchProvider - local State Manipulation', () {
    setUp(() {
      final user = MockUser();
      when(() => user.id).thenReturn('u1');
      when(() => mockAuth.currentUser).thenReturn(user);
    });

    test('addBatch works without touching the network', () async {
      await batchProvider.addBatch(
        name: 'Batch A',
        typeOfBird: 'broiler',
        initialCount: 50,
        age: 3,
        ageUnit: 'weeks',
        purchaseCost: 200,
      );

      expect(batchProvider.batches.single.name, 'Batch A');
      expect(sync.pendingCount, 1);
      verifyNever(() => mockSupabase.from(any()));
    });

    test(
      'RemoveBatches removes item from local list and triggers listeners',
      () async {
        // arrange
        await batchProvider.addBatch(
          name: 'Batch A',
          typeOfBird: 'broiler',
          initialCount: 50,
          age: 3,
          ageUnit: 'weeks',
          purchaseCost: 200,
        );
        final id = batchProvider.batches.single.id;

        bool listenerCalled = false;
        batchProvider.addListener(() {
          listenerCalled = true;
        });

        // act
        await batchProvider.removeBatch(id);

        // assert
        expect(listenerCalled, isTrue);
        expect(batchProvider.batches, isEmpty);
        expect(sync.outbox.deletedIds(LocalTables.batches), {id});
      },
    );
  });
}

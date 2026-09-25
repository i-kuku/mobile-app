import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {
  @override
  Future<R> then<R>(
    FutureOr<R> Function(dynamic value) onValue, {
    Function? onError,
  }) {
    // Automatically resolves as a completed Future containing an empty list (or mock response)
    return Future.value(onValue([]));
  }
}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late BatchProvider batchProvider;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    batchProvider = BatchProvider(supabase: mockSupabase);
  });

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
    test(
      'RemoveBatches removes item from local list and triggers listeners',
      () async {
        // arrange
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder();

        when(
          () => mockSupabase.from('batches'),
        ).thenAnswer((_) => mockQueryBuilder);
        when(
          () => mockQueryBuilder.delete(),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.eq('id', '123'),
        ).thenAnswer((_) => mockFilterBuilder);

        bool listenerCalled = false;
        batchProvider.addListener(() {
          listenerCalled = true;
        });

        // act
        await batchProvider.removeBatch('123');

        // assert
        expect(listenerCalled, isTrue);
        verify(() => mockSupabase.from('batches')).called(1);
      },
    );
  });
}

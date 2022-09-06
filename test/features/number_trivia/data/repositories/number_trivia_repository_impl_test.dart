import 'package:dartz/dartz.dart';
import 'package:flutter_tdd/core/error/exceptions.dart';
import 'package:flutter_tdd/core/error/failures.dart';
import 'package:flutter_tdd/core/network/network_info.dart';
import 'package:flutter_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:flutter_tdd/features/number_trivia/data/source/number_trivia_local_source.dart';
import 'package:flutter_tdd/features/number_trivia/data/source/number_trivia_remote_source.dart';
import 'package:flutter_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

import 'number_trivia_repository_impl_test.mocks.dart';

class RemoteDataSourceTest extends Mock implements NumberTriviaRemoteSource {}

class LocalDataSourceTest extends Mock implements NumberTriviaLocalSource {}

class NetworkInfoTest extends Mock implements NetworkInfo {}

@GenerateMocks([RemoteDataSourceTest, LocalDataSourceTest, NetworkInfoTest])
void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSourceTest mockRemoteDataSourceTest;
  late MockLocalDataSourceTest mockLocalDataSourceTest;
  late MockNetworkInfoTest mockNetworkInfoTest;

  const tNumber = 1;
  const tNumberTriviaModel = NumberTriviaModel(text: "test", number: tNumber);
  const NumberTrivia tNumberTrivia = tNumberTriviaModel;

  setUp(() {
    mockRemoteDataSourceTest = MockRemoteDataSourceTest();
    mockLocalDataSourceTest = MockLocalDataSourceTest();
    mockNetworkInfoTest = MockNetworkInfoTest();
    repository = NumberTriviaRepositoryImpl(
        remoteSource: mockRemoteDataSourceTest,
        localSource: mockLocalDataSourceTest,
        networkInfo: mockNetworkInfoTest);
  });

  void runTestOnline(Function block) {
    group("device is online", () {
      setUp(() {
        when(mockNetworkInfoTest.isConnected).thenAnswer((_) async => true);
      });

      // block body for writing code
      block();
    });
  }

  void runTestOffline(Function block) {
    group("device is offline", () {
      setUp(() {
        when(mockNetworkInfoTest.isConnected).thenAnswer((_) async => false);
      });

      // block body for writing code
      block();
    });
  }

  group("getConcreteNumberTrivia", () {
    setUp(() {
      when(mockRemoteDataSourceTest.getConcreteNumberTrivia(any))
          .thenAnswer((_) async => tNumberTriviaModel);
    });

    test("should check if the device is online", () async {
      // arrange
      when(mockNetworkInfoTest.isConnected).thenAnswer((_) async => true);
      // act
      await repository.getConcreteNumberTrivia(tNumber);
      // assert
      verify(mockNetworkInfoTest.isConnected);
    });

    runTestOnline(() {
      test(
        "should return remote data when the call to remote data source is successful",
        () async {
          // arrange
          when(mockRemoteDataSourceTest.getConcreteNumberTrivia(any))
              .thenAnswer((realInvocation) async => tNumberTriviaModel);
          // act
          final actual = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockRemoteDataSourceTest.getConcreteNumberTrivia(tNumber));
          expect(actual, equals(const Right(tNumberTrivia)));
        },
      );

      test(
        "should cache data locally when the call to remote data source is successful",
        () async {
          // arrange
          when(mockRemoteDataSourceTest.getConcreteNumberTrivia(any))
              .thenAnswer((realInvocation) async => tNumberTriviaModel);
          // act
          await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockRemoteDataSourceTest.getConcreteNumberTrivia(tNumber));
          verify(
              mockLocalDataSourceTest.cachedNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        "should return failure when the call to remote data source is unsuccessful",
        () async {
          // arrange
          when(mockRemoteDataSourceTest.getConcreteNumberTrivia(any))
              .thenThrow(ServerException());
          // act
          final actual = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockRemoteDataSourceTest.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSourceTest);
          expect(actual, equals(Left(ServerFailure())));
        },
      );
    });

    runTestOffline(() {
      test(
        'should return last locally data when cache data is present',
        () async {
          // arrange
          when(mockLocalDataSourceTest.getLastNumberTrivia())
              .thenAnswer((realInvocation) async => tNumberTriviaModel);

          // act
          final actual = await repository.getConcreteNumberTrivia(tNumber);

          // assert
          verifyZeroInteractions(mockRemoteDataSourceTest);
          verify(mockLocalDataSourceTest.getLastNumberTrivia());
          expect(actual, equals(const Right(tNumberTrivia)));
        },
      );

      test(
        'should return failure when cache data is no cache data present',
        () async {
          // arrange
          when(mockLocalDataSourceTest.getLastNumberTrivia())
              .thenThrow(CacheException());

          // act
          final actual = await repository.getConcreteNumberTrivia(tNumber);

          // assert
          verifyZeroInteractions(mockRemoteDataSourceTest);
          verify(mockLocalDataSourceTest.getLastNumberTrivia());
          expect(actual, equals(Left(CacheFailure())));
        },
      );
    });
  }); 

  group("getRandomNumberTrivia", () {
    setUp(() {
      when(mockRemoteDataSourceTest.getRandomNumberTrivia())
          .thenAnswer((_) async => tNumberTriviaModel);
    });

    test("should check if the device is online", () async {
      // arrange
      when(mockNetworkInfoTest.isConnected).thenAnswer((_) async => true);
      // act
      await repository.getRandomNumberTrivia();
      // assert
      verify(mockNetworkInfoTest.isConnected);
    });

    runTestOnline(() {
      test(
        "should return remote data when the call to remote data source is successful",
        () async {
          // arrange
          when(mockRemoteDataSourceTest.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final actual = await repository.getRandomNumberTrivia();
          // assert
          verify(mockRemoteDataSourceTest.getRandomNumberTrivia());
          expect(actual, equals(const Right(tNumberTrivia)));
        },
      );

      test(
        "should cache data locally when the call to remote data source is successful",
        () async {
          // arrange
          when(mockRemoteDataSourceTest.getRandomNumberTrivia())
              .thenAnswer((realInvocation) async => tNumberTriviaModel);
          // act
          await repository.getRandomNumberTrivia();
          // assert
          verify(mockRemoteDataSourceTest.getRandomNumberTrivia());
          verify(
              mockLocalDataSourceTest.cachedNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        "should return failure when the call to remote data source is unsuccessful",
        () async {
          // arrange
          when(mockRemoteDataSourceTest.getRandomNumberTrivia())
              .thenThrow(ServerException());
          // act
          final actual = await repository.getRandomNumberTrivia();
          // assert
          verify(mockRemoteDataSourceTest.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalDataSourceTest);
          expect(actual, equals(Left(ServerFailure())));
        },
      );
    });

    runTestOffline(() {
      test(
        'should return last locally data when cache data is present',
        () async {
          // arrange
          when(mockLocalDataSourceTest.getLastNumberTrivia())
              .thenAnswer((realInvocation) async => tNumberTriviaModel);

          // act
          final actual = await repository.getRandomNumberTrivia();

          // assert
          verifyZeroInteractions(mockRemoteDataSourceTest);
          verify(mockLocalDataSourceTest.getLastNumberTrivia());
          expect(actual, equals(const Right(tNumberTrivia)));
        },
      );

      test(
        'should return failure when cache data is no cache data present',
        () async {
          // arrange
          when(mockLocalDataSourceTest.getLastNumberTrivia())
              .thenThrow(CacheException());

          // act
          final actual = await repository.getRandomNumberTrivia();

          // assert
          verifyZeroInteractions(mockRemoteDataSourceTest);
          verify(mockLocalDataSourceTest.getLastNumberTrivia());
          expect(actual, equals(Left(CacheFailure())));
        },
      );
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_tdd/core/error/failures.dart';
import 'package:flutter_tdd/core/usecases/usecase.dart';
import 'package:flutter_tdd/core/utils/input_converter.dart';
import 'package:flutter_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'number_trivia_bloc_test.mocks.dart';

class GetConcreteNumberTriviaTest extends Mock
    implements GetConcreteNumberTrivia {}

class GetRandomNumberTriviaTest extends Mock implements GetRandomNumberTrivia {}

class InputConverterTest extends Mock implements InputConvert {}

@GenerateMocks([
  GetConcreteNumberTriviaTest,
  GetRandomNumberTriviaTest,
  InputConverterTest
])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTriviaTest mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTriviaTest mockGetRandomNumberTrivia;
  late MockInputConverterTest mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTriviaTest();
    mockGetRandomNumberTrivia = MockGetRandomNumberTriviaTest();
    mockInputConverter = MockInputConverterTest();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConvert: mockInputConverter,
    );
  });

  test('initialState should be OnIdle', () {
    // assert
    expect(bloc.state, equals(OnIdle()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = "1";
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: "test", number: 1);

    void setUpMockInputConverterSuccess() {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(const Right(tNumberParsed));
    }

    test(
      "should call the InputConverter to validation and convert the string to an unsignedInteger",
      () async {
        // arrange
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        setUpMockInputConverterSuccess();
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));

        /// We await untilCalled() because the logic inside a Bloc is triggered
        /// through a Stream<Event> which is, of course, asynchronous itself.
        /// Had we not awaited until the stringToUnsignedInteger has been called,
        /// the verification would always fail, since we'd verify before the
        /// code had a chance to execute.
        await untilCalled(mockInputConverter.stringToUnsignedInteger(any));

        // assert
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    test(
      "should emit [Error] when the input is invalid",
      () async {
        // arrange
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));

        /// Instead of the usual arrange -> act -> assert, we instead
        /// arrange -> assert later -> act. It is usually not be necessary to
        /// call expectLater before actually dispatching the event because it
        /// takes some time before a Stream emits its first value. I like to
        /// err on the safe side though.
        // assert later
        final expectedOrderEmits = [
          OnLoading(),
          const OnError(errorMessage: invalidInputFailureMessage),
        ];
        expectLater(
          bloc.stream,
          emitsInOrder(expectedOrderEmits),
        );
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      'should get data from the concrete use case',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(mockGetConcreteNumberTrivia(any));
        // assert
        verify(
            mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
      },
    );

    test(
      "should emit [OnLoading, OnComplete] when data is gotten successfully",
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));

        /// Instead of the usual arrange -> act -> assert, we instead
        /// arrange -> assert later -> act. It is usually not be necessary to
        /// call expectLater before actually dispatching the event because it
        /// takes some time before a Stream emits its first value. I like to
        /// err on the safe side though.
        // assert later
        final expectedOrderEmits = [
          OnLoading(),
          const OnComplete(trivia: tNumberTrivia),
        ];
        expectLater(
          bloc.stream,
          emitsInOrder(expectedOrderEmits),
        );
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      "should emit [OnLoading, OnError] when getting data fails",
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));

        /// Instead of the usual arrange -> act -> assert, we instead
        /// arrange -> assert later -> act. It is usually not be necessary to
        /// call expectLater before actually dispatching the event because it
        /// takes some time before a Stream emits its first value. I like to
        /// err on the safe side though.
        // assert later
        final expectedOrderEmits = [
          OnLoading(),
          const OnError(errorMessage: serverFailureMessage)
        ];
        expectLater(
          bloc.stream,
          emitsInOrder(expectedOrderEmits),
        );
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      "should emit [OnLoading, OnError] whit a proper message for the error when getting data fails",
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));

        /// Instead of the usual arrange -> act -> assert, we instead
        /// arrange -> assert later -> act. It is usually not be necessary to
        /// call expectLater before actually dispatching the event because it
        /// takes some time before a Stream emits its first value. I like to
        /// err on the safe side though.
        // assert later
        final expectedOrderEmits = [
          OnLoading(),
          const OnError(errorMessage: cacheFailureMessage)
        ];
        expectLater(
          bloc.stream,
          emitsInOrder(expectedOrderEmits),
        );
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );
  });

  group('GetRandomForConcreteNumber', () {
    const tNumberTrivia = NumberTrivia(text: "test", number: 1);

    test(
      'should get data from the random use case',
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        // act
        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(mockGetRandomNumberTrivia(any));
        // assert
        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      "should emit [OnLoading, OnComplete] when data is gotten successfully",
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        // assert later
        final expectedOrderEmits = [
          OnLoading(),
          const OnComplete(trivia: tNumberTrivia),
        ];
        expectLater(
          bloc.stream,
          emitsInOrder(expectedOrderEmits),
        );
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      "should emit [OnLoading, OnError] when getting data fails",
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));

        /// Instead of the usual arrange -> act -> assert, we instead
        /// arrange -> assert later -> act. It is usually not be necessary to
        /// call expectLater before actually dispatching the event because it
        /// takes some time before a Stream emits its first value. I like to
        /// err on the safe side though.
        // assert later
        final expectedOrderEmits = [
          OnLoading(),
          const OnError(errorMessage: serverFailureMessage)
        ];
        expectLater(
          bloc.stream,
          emitsInOrder(expectedOrderEmits),
        );
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      "should emit [OnLoading, OnError] whit a proper message for the error when getting data fails",
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expectedOrderEmits = [
          OnLoading(),
          const OnError(errorMessage: cacheFailureMessage)
        ];
        expectLater(
          bloc.stream,
          emitsInOrder(expectedOrderEmits),
        );
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      "should emit [OnLoading, OnError] with a null message for the error when getting data fails",
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => null);
        // assert later
        final expectedOrderEmits = [
          OnLoading(),
          const OnError(errorMessage: nullResultFailureMessage)
        ];
        expectLater(
          bloc.stream,
          emitsInOrder(expectedOrderEmits),
        );
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );
  });
}

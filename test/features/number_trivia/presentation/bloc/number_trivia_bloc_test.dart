import 'package:dartz/dartz.dart';
import 'package:flutter_tdd/core/error/failures.dart';
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

    test(
      "should call the InputConverter to validation and convert the string to an unsignedInteger",
      () async {
        // arrange
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(const Right(tNumberParsed));
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
  });
}

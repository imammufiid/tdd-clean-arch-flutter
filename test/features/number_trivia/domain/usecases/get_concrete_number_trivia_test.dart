import 'package:dartz/dartz.dart';
import 'package:flutter_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'get_concrete_number_trivia_test.mocks.dart';

class NumberTriviaRepositoryTest extends Mock
    implements NumberTriviaRepository {}

@GenerateMocks([NumberTriviaRepositoryTest])
void main() {
  late GetConcreteNumberTrivia useCase;
  late MockNumberTriviaRepositoryTest mockNumberTriviaRepository;

  const tNumber = 1;
  const tNumberTrivia = NumberTrivia(text: "test", number: tNumber);

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepositoryTest();
    useCase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });

  test(
    'should get trivia for the number from the repository',
    () async {
      // arrange
      when(mockNumberTriviaRepository.getConcreteNumberTrivia(any))
          .thenAnswer((realInvocation) async => const Right(tNumberTrivia));

      // act
      final result = await useCase(const Params(number: tNumber));

      // assert
      expect(result, const Right(tNumberTrivia));
      verify(mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber));
      verifyNoMoreInteractions(mockNumberTriviaRepository);
    },
  );
}

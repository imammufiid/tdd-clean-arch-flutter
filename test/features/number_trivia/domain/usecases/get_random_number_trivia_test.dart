import 'package:dartz/dartz.dart';
import 'package:flutter_tdd/core/usecases/usecase.dart';
import 'package:flutter_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_random_number_trivia_test.mocks.dart';

class NumberTriviaRepositoryTest extends Mock
    implements NumberTriviaRepository {}

@GenerateMocks([NumberTriviaRepositoryTest])
void main() {
  late GetRandomNumberTrivia useCase;
  late MockNumberTriviaRepositoryTest mockNumberTriviaRepositoryTest;

  const mockReturnRepository = NumberTrivia(text: "test", number: 1);

  setUp(() {
    mockNumberTriviaRepositoryTest = MockNumberTriviaRepositoryTest();
    useCase = GetRandomNumberTrivia(mockNumberTriviaRepositoryTest);
  });

  test(
    "should get trivia for the random number from the repository",
    () async {
      // arrange
      when(mockNumberTriviaRepositoryTest.getRandomNumberTrivia())
          .thenAnswer((_) async => const Right(mockReturnRepository));

      // act
      final actual = await useCase(NoParams());

      // assert
      expect(actual, const Right(mockReturnRepository));
      verify(mockNumberTriviaRepositoryTest.getRandomNumberTrivia());
      verifyNoMoreInteractions(mockNumberTriviaRepositoryTest);
    },
  );
}

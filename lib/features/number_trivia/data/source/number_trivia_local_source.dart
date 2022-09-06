import 'package:flutter_tdd/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaLocalSource {
  Future<NumberTriviaModel> getLastNumberTrivia();
  Future<void> cachedNumberTrivia(NumberTriviaModel triviaToCache);
}

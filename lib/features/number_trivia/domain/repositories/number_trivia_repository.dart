import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/number_trivia.dart';

abstract class NumberTriviaRepository {
  Future<Either<Failures, NumberTrivia>>? getConcreteNumberTrivia(int? number);
  Future<Either<Failures, NumberTrivia>>? getRandomNumberTrivia();
}
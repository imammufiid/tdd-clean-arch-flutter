import 'package:flutter_tdd/core/error/exceptions.dart';
import 'package:flutter_tdd/core/platform/network_info.dart';
import 'package:flutter_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_tdd/features/number_trivia/data/source/number_trivia_local_source.dart';
import 'package:flutter_tdd/features/number_trivia/data/source/number_trivia_remote_source.dart';
import 'package:flutter_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_tdd/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';

typedef Future<NumberTriviaModel> _ConcreteOrRandomChooser();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteSource remoteSource;
  final NumberTriviaLocalSource localSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    required this.remoteSource,
    required this.localSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, NumberTrivia>>? getConcreteNumberTrivia(int? number) {
    return _getTrivia(() => remoteSource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failures, NumberTrivia>>? getRandomNumberTrivia() {
    return _getTrivia(() => remoteSource.getRandomNumberTrivia());
  }

  Future<Either<Failures, NumberTrivia>>? _getTrivia(
      _ConcreteOrRandomChooser block,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await block();
        localSource.cachedNumberTrivia(result);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final result = await localSource.getLastNumberTrivia();
        return (Right(result));
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}

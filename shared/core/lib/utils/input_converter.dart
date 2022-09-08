import 'package:dependencies/dartz/dartz.dart';

import '../error/failures.dart';

class InputConvert {
  Either<Failures, int> stringToUnsignedInteger(String value) {
    try {
      final integer = int.parse(value);
      if (integer < 0) throw const FormatException();
      return Right(integer);
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}

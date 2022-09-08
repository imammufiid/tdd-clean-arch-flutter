import 'package:core/error/failures.dart';
import 'package:core/utils/input_converter.dart';
import 'package:dependencies/dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputConvert inputConvert;

  setUp(() {
    inputConvert = InputConvert();
  });

  group('StringToUnsingedInt', () {
    test(
      'should return an integer when the string represents an unsigned integer',
      () async {
        // arrange
        const str = "123";
        // act
        final result = inputConvert.stringToUnsignedInteger(str);
        // assert
        expect(result, const Right(123));
      },
    );

    test(
      'should return InvalidInputFailure when the string is double',
      () async {
        // arrange
        const str = "123.7";
        // act
        final actual = inputConvert.stringToUnsignedInteger(str);
        // assert
        expect(actual, Left(InvalidInputFailure()));
      },
    );

    test(
      'should return InvalidInputFailure when the string is char',
          () async {
        // arrange
        const str = "asdf";
        // act
        final actual = inputConvert.stringToUnsignedInteger(str);
        // assert
        expect(actual, Left(InvalidInputFailure()));
      },
    );

    test(
      'should return InvalidInputFailure when the string is negative integer',
          () async {
        // arrange
        const str = "-123";
        // act
        final actual = inputConvert.stringToUnsignedInteger(str);
        // assert
        expect(actual, Left(InvalidInputFailure()));
      },
    );
  });
}

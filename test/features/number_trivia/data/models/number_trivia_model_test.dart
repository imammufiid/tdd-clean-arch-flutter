import 'dart:convert';

import 'package:flutter_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tNumberTriviaModel = NumberTriviaModel(number: 1, text: "Test Text");

  test("should be a subclass of NumberTrivia entity", () {
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group("fromJson", () {
    test(
      "should return a valid model when the JSON number is an integer",
      () async {
        // arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture("trivia.json"));

        // act
        final actual = NumberTriviaModel.fromJson(jsonMap);

        // expect
        expect(actual, tNumberTriviaModel);
      },
    );

    test("should return a valid model when the JSON number is an double",
        () async {
      final Map<String, dynamic> jsonMap =
          json.decode(fixture("trivia_double.json"));

      final actual = NumberTriviaModel.fromJson(jsonMap);
      expect(actual, tNumberTriviaModel);
    });
  });

  group("toJson", () {
    test("should return JSON map containing the proper data", () async {
      final Map<String, dynamic> jsonMap = {"text": "Test Text", "number": 1};

      expect(tNumberTriviaModel.toJson(), jsonMap);
    });
  });
}

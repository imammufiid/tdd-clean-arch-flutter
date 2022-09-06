import 'dart:convert';

import 'package:flutter_tdd/core/error/exceptions.dart';
import 'package:flutter_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_tdd/features/number_trivia/data/source/number_trivia_local_source.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_source_test.mocks.dart';

class SharedPreferencesTest extends Mock implements SharedPreferences {}

@GenerateMocks([SharedPreferencesTest])
void main() {
  late MockSharedPreferencesTest mockSharedPreferences;
  late NumberTriviaLocalSourceImpl localSource;

  setUp(() {
    mockSharedPreferences = MockSharedPreferencesTest();
    localSource =
        NumberTriviaLocalSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group("getLastNumberTrivia", () {
    final jsonNumberTriviaCache = fixture('trivia_cache.json');
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(jsonNumberTriviaCache));

    test(
      "should return NumberTrivia from SharedPreferences when there is one in the cache",
      () async {
        // arrange
        when(mockSharedPreferences.getString(any))
            .thenReturn(jsonNumberTriviaCache);

        // act
        final actual = await localSource.getLastNumberTrivia();

        // assert
        verify(mockSharedPreferences.getString(KEY_NUMBER_TRIVIA));
        expect(actual, equals(tNumberTriviaModel));
      },
    );

    test(
      "should Throw a CacheException when there is not a cached value",
      () async {
        // arrange
        when(mockSharedPreferences.getString(any))
            .thenReturn(null);

        // act
        final call = localSource.getLastNumberTrivia;

        // assert
        expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
      },
    );
  });
  
  group("cacheNumberTrivia", () {
    const tNumberTriviaModel = NumberTriviaModel(text: "test", number: 1);

    test("should call SharedPreferences to cache the data", () {
      // arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);
      // act
      localSource.cachedNumberTrivia(tNumberTriviaModel);
      // assert
      final expectedJson = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(KEY_NUMBER_TRIVIA, expectedJson));
    });
  });
}

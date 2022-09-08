import 'dart:convert';

import 'package:flutter_tdd/core/error/exceptions.dart';
import 'package:flutter_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:dependencies/shared_preferences/shared_preferences.dart';

const KEY_NUMBER_TRIVIA = "number_trivia";

abstract class NumberTriviaLocalSource {
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void>? cachedNumberTrivia(NumberTriviaModel triviaToCache);
}

class NumberTriviaLocalSourceImpl implements NumberTriviaLocalSource {
  final SharedPreferences sharedPreferences;

  NumberTriviaLocalSourceImpl({required this.sharedPreferences});

  @override
  Future<void>? cachedNumberTrivia(NumberTriviaModel triviaToCache) {
    return sharedPreferences.setString(
      KEY_NUMBER_TRIVIA,
      json.encode(triviaToCache.toJson()),
    );
  }

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final result = sharedPreferences.getString(KEY_NUMBER_TRIVIA);
    if (result != null) {
      return Future.value(NumberTriviaModel.fromJson(jsonDecode(result)));
    } else {
      throw CacheException();
    }
  }
}

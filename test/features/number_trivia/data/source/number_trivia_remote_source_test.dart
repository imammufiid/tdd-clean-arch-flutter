import 'dart:convert';

import 'package:core/error/exceptions.dart';
import 'package:flutter_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_tdd/features/number_trivia/data/source/number_trivia_remote_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dependencies/http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_source_test.mocks.dart';

class HttpClientTest extends Mock implements http.Client {}

@GenerateMocks([HttpClientTest])
void main() {
  late NumberTriviaRemoteSourceImpl remoteSource;
  late MockHttpClientTest mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClientTest();
    remoteSource = NumberTriviaRemoteSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response("Something went wrong", 404));
  }

  group("getConcreteNumberTrivia", () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number 
      being the endpoint and with application/json header''',
      () async {
        final uri = Uri.parse("http://numbersapi.com/$tNumber");
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        remoteSource.getConcreteNumberTrivia(tNumber);
        // expect
        verify(mockHttpClient.get(
          uri,
          headers: {'Content-Type': 'application/json'},
        ));
      },
    );

    test(
      "should return NumberTrivia when the response code is 200 (success)",
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        final actual = await remoteSource.getConcreteNumberTrivia(tNumber);
        // assert
        expect(actual, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = remoteSource.getConcreteNumberTrivia;
        // assert
        expect(
            () => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
      },
    );
  });

  group("getRandomNumberTrivia", () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL 
    being the endpoint and with application/json header''',
      () async {
        final uri = Uri.parse("http://numbersapi.com/random");
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        remoteSource.getRandomNumberTrivia();
        // assert
        verify(mockHttpClient
            .get(uri, headers: {'Content-Type': 'application/json'}));
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        setUpMockHttpClientSuccess200();
        // act
        final actual = await remoteSource.getRandomNumberTrivia();
        // assert
        expect(actual, equals(tNumberTriviaModel));
      },
    );

    test(
      "should throw a ServerException when the response code is 404 or other",
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = remoteSource.getRandomNumberTrivia;
        // assert
        expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
      },
    );
  });
}

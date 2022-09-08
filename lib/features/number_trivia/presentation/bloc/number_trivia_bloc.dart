import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tdd/core/error/failures.dart';
import 'package:flutter_tdd/core/usecases/usecase.dart';
import 'package:flutter_tdd/core/utils/input_converter.dart';
import 'package:flutter_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';

part 'number_trivia_state.dart';

const String serverFailureMessage = "Server Failure";
const String cacheFailureMessage = "Cache Failure";
const String invalidInputFailureMessage =
    "Invalid Input Failure - The number must be a positive integer or zero";
const String nullResultFailureMessage = "null value";

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConvert inputConvert;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConvert,
  }) : super(OnIdle()) {
    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(OnLoading());
      final result = await getRandomNumberTrivia(NoParams());
      if (result != null) {
        _eitherOnCompleteOrOnErrorState(emit, result);
      } else {
        emit(const OnError(errorMessage: nullResultFailureMessage));
      }
    });

    on<GetTriviaForConcreteNumber>((event, emit) {
      final inputEither =
          inputConvert.stringToUnsignedInteger(event.numberString);
      emit(OnLoading());

      inputEither.fold(
        (failure) {
          emit(const OnError(errorMessage: invalidInputFailureMessage));
        },
        (value) async {
          final result = await getConcreteNumberTrivia(Params(number: value));
          if (result != null) {
            _eitherOnCompleteOrOnErrorState(emit, result);
          } else {
            emit(const OnError(errorMessage: nullResultFailureMessage));
          }
        },
      );
    });
  }

  void _eitherOnCompleteOrOnErrorState(
      Emitter<NumberTriviaState> emit, Either<Failures, NumberTrivia> result) {
    emit(
      result.fold(
        (failure) => OnError(errorMessage: _mapFailureToMessage(failure)),
        (trivia) => OnComplete(trivia: trivia),
      ),
    );
  }

  String _mapFailureToMessage(Failures failures) {
    switch (failures.runtimeType) {
      case ServerFailure:
        return serverFailureMessage;
      case CacheFailure:
        return cacheFailureMessage;
      default:
        return "Unexpected Error";
    }
  }
}

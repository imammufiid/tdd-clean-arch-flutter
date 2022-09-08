part of 'number_trivia_bloc.dart';

abstract class NumberTriviaState extends Equatable {
  const NumberTriviaState();

  @override
  List<Object> get props => [];
}

class OnIdle extends NumberTriviaState {}

class OnLoading extends NumberTriviaState {}

class OnComplete extends NumberTriviaState {
  final NumberTrivia trivia;

  const OnComplete({required this.trivia});

  @override
  List<Object> get props => [trivia];
}

class OnError extends NumberTriviaState {
  final String errorMessage;

  const OnError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

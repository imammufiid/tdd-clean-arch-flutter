import 'package:equatable/equatable.dart';

abstract class Failures extends Equatable {
  const Failures([List properties = const<dynamic>[]]);
}

// General Failure
class ServerFailure extends Failures {
  @override 
  List<Object?> get props => [const<dynamic>[]];
}

class CacheFailure extends Failures {
  @override
  List<Object?> get props => [const<dynamic>[]];
}

class InvalidInputFailure extends Failures {
  @override
  List<Object?> get props => [const<dynamic>[]];
}
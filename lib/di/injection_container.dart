import 'package:core/network/network_info.dart';
import 'package:core/utils/input_converter.dart';
import 'package:flutter_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:flutter_tdd/features/number_trivia/data/source/number_trivia_local_source.dart';
import 'package:flutter_tdd/features/number_trivia/data/source/number_trivia_remote_source.dart';
import 'package:flutter_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dependencies/getit/get_it.dart';
import 'package:dependencies/internet_conn_checker/internet_conn_checker.dart';
import 'package:dependencies/shared_preferences/shared_preferences.dart';
import 'package:dependencies/http/http.dart' as http;

Future<void> init() async {
  /// Features
  // Bloc
  sl.registerFactory(
    () => NumberTriviaBloc(
      getConcreteNumberTrivia: sl(),
      getRandomNumberTrivia: sl(),
      inputConvert: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(sl()));

  // Repository
  sl.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      remoteSource: sl(),
      localSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data source
  sl.registerLazySingleton<NumberTriviaRemoteSource>(
    () => NumberTriviaRemoteSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<NumberTriviaLocalSource>(
    () => NumberTriviaLocalSourceImpl(sharedPreferences: sl()),
  );

  /// Core
  sl.registerLazySingleton(() => InputConvert());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  /// External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}

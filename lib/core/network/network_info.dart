import 'package:dependencies/internet_conn_checker/internet_conn_checker.dart';

abstract class NetworkInfo {
  Future<bool>? get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker internetConnectionChecker;

  NetworkInfoImpl(this.internetConnectionChecker);

  @override
  Future<bool>? get isConnected => internetConnectionChecker.hasConnection;

}
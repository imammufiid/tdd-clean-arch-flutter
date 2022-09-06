import 'package:flutter_tdd/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'network_info_test.mocks.dart';

class DataConnectionCheckerTest extends Mock implements InternetConnectionChecker {}

@GenerateMocks([DataConnectionCheckerTest])
void main() {
  late MockDataConnectionCheckerTest dataConnectionCheckerTest;
  late NetworkInfoImpl networkInfo;

  setUp(() {
    dataConnectionCheckerTest = MockDataConnectionCheckerTest();
    networkInfo = NetworkInfoImpl(dataConnectionCheckerTest);
  });

  group("isConnected", () {
    test(
      "should forward the call to DataConnection.hasConnection",
      () async {
        final tHasConnection = Future.value(true);
        // arrange
        when(dataConnectionCheckerTest.hasConnection)
            .thenAnswer((_) => tHasConnection);

        // act
        final actual = networkInfo.isConnected;

        // assert
        verify(dataConnectionCheckerTest.hasConnection);
        expect(actual, tHasConnection);
      },
    );
  });
}

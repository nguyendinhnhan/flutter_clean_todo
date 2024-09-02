import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  void monitorNetworkChanges(Function onConnected) {
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      print("results: $results");
      if (results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none)) {
        onConnected();
      }
    });
  }
}

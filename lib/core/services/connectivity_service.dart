import 'package:connectivity_plus/connectivity_plus.dart';

/// DoneDrop Connectivity Service
class ConnectivityService {
  ConnectivityService._();
  static ConnectivityService get instance => ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(
        (results) => results.any((r) => r != ConnectivityResult.none),
      );
}

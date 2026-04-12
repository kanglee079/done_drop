import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service that monitors network connectivity.
/// Exposes a reactive `isOnline` stream so any service/widget can listen.
class ConnectivityService extends GetxService {
  ConnectivityService();

  final _connectivity = Connectivity();
  final RxBool isOnline = true.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Callbacks registered for connectivity changes.
  final List<void Function(bool isOnline)> _listeners = [];

  Future<ConnectivityService> init() async {
    // Check initial state
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);

    return this;
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
    isOnline.value = hasConnection;

    // Notify all registered listeners
    for (final listener in _listeners) {
      listener(hasConnection);
    }
  }

  /// Register a callback that fires when connectivity changes.
  /// Returns an unsubscribe function.
  void Function() onConnectivityChanged(void Function(bool isOnline) callback) {
    _listeners.add(callback);
    return () => _listeners.remove(callback);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

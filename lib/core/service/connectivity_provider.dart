import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// StateNotifier to monitor connectivity
class ConnectivityNotifier extends StateNotifier<AsyncValue<String>> {
  ConnectivityNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;

  void _init() {
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged as Stream<ConnectivityResult>;

    // Listen to connectivity changes
    _connectivityStream.listen((result) {
      final isOnline = result != ConnectivityResult.none;
      if (isOnline) {
        state = const AsyncValue.data('Back online');
      } else {
        state = const AsyncValue.data('You are offline');
      }
    });

    // Initial check
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isOnline = result != ConnectivityResult.none;
      if (isOnline) {
        state = const AsyncValue.data('Back online');
      } else {
        state = const AsyncValue.data('You are offline');
      }
    } catch (e, st) {
      state = AsyncValue.error('Failed to check connectivity', st);
    }
  }
}

/// Provider for connectivity
final connectivityNotifierProvider =
    StateNotifierProvider<ConnectivityNotifier, AsyncValue<String>>(
  (ref) => ConnectivityNotifier(),
);

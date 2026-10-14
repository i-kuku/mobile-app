import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tracks whether the app can reach the server.
///
/// A network interface being up isn't enough: rural Wi-Fi and mobile data
/// often connect without passing traffic. So [isOnline] also needs the last
/// request to have got through, as reported by [reportReachable] and
/// [reportUnreachable].
class ConnectivityService extends ChangeNotifier {
  ConnectivityService({
    Stream<bool>? interfaceChanges,
    Future<bool> Function()? checkInterface,
  }) : _interfaceChanges = interfaceChanges,
       _checkInterface = checkInterface;

  /// Uses the device's network state via connectivity_plus.
  factory ConnectivityService.device() {
    final connectivity = Connectivity();
    return ConnectivityService(
      interfaceChanges: connectivity.onConnectivityChanged.map(_hasInterface),
      checkInterface: () async =>
          _hasInterface(await connectivity.checkConnectivity()),
    );
  }

  /// A service that always reports [online]; for tests.
  factory ConnectivityService.fixed({bool online = true}) =>
      ConnectivityService().._hasNetwork = online;

  static bool _hasInterface(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  final Stream<bool>? _interfaceChanges;
  final Future<bool> Function()? _checkInterface;
  StreamSubscription<bool>? _subscription;

  // Optimistic until told otherwise, so the first sync is attempted.
  bool _hasNetwork = true;
  bool _reachable = true;

  /// Whether a network interface is up.
  bool get hasNetwork => _hasNetwork;

  /// Whether requests are expected to reach the server.
  bool get isOnline => _hasNetwork && _reachable;

  Future<void> start() async {
    final check = _checkInterface;
    if (check != null) {
      try {
        _setNetwork(await check());
      } catch (e) {
        debugPrint('[Connectivity] Could not read network state: $e');
      }
    }
    _subscription ??= _interfaceChanges?.listen(
      _setNetwork,
      onError: (Object e) =>
          debugPrint('[Connectivity] Network state stream failed: $e'),
    );
  }

  void _setNetwork(bool hasNetwork) {
    final wasOnline = isOnline;
    // Any change in the network, such as moving from Wi-Fi to mobile data,
    // is a cue to try the server again.
    if (hasNetwork) _reachable = true;
    _hasNetwork = hasNetwork;
    if (wasOnline != isOnline) notifyListeners();
  }

  /// Simulates the interface going up or down; for tests.
  @visibleForTesting
  void setNetworkForTest(bool hasNetwork) => _setNetwork(hasNetwork);

  /// A request just reached the server.
  void reportReachable() {
    if (_reachable) return;
    final wasOnline = isOnline;
    _reachable = true;
    // Seeing a response proves there's a network, whatever the OS says.
    _hasNetwork = true;
    if (wasOnline != isOnline) notifyListeners();
  }

  /// A request failed to reach the server.
  void reportUnreachable() {
    if (!_reachable) return;
    final wasOnline = isOnline;
    _reachable = false;
    if (wasOnline != isOnline) notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

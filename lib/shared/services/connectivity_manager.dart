import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'offline_service.dart';
import 'offline_data_service.dart';

class ConnectivityManager {
  static ConnectivityManager? _instance;
  static ConnectivityManager get instance =>
      _instance ??= ConnectivityManager._();

  ConnectivityManager._();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = false;
  bool _autoSyncEnabled = true;

  final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> pendingReportsNotifier = ValueNotifier<int>(0);

  bool get isOnline => _isOnline;
  bool get autoSyncEnabled => _autoSyncEnabled;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      ConnectivityResult result,
    ) async {
      await _handleConnectivityChange(result);
    });

    // Update pending reports count
    await _updatePendingReportsCount();

    print('[ConnectivityManager] Initialized - Online: $_isOnline');
  }

  /// Handle connectivity changes
  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    final wasOnline = _isOnline;
    await _checkConnectivity();

    if (!wasOnline && _isOnline) {
      print('[ConnectivityManager] Device came online');

      // Auto-sync if enabled
      if (_autoSyncEnabled) {
        await _performAutoSync();
      }
    } else if (wasOnline && !_isOnline) {
      print('[ConnectivityManager] Device went offline');
    }

    await _updatePendingReportsCount();
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final wasOnline = _isOnline;

      if (connectivityResult == ConnectivityResult.none) {
        _isOnline = false;
      } else {
        // Additional check with actual network request
        _isOnline = await OfflineService.instance.isOnline();
      }

      if (wasOnline != _isOnline) {
        isOnlineNotifier.value = _isOnline;
      }
    } catch (e) {
      print('[ConnectivityManager] Error checking connectivity: $e');
      _isOnline = false;
      isOnlineNotifier.value = false;
    }
  }

  /// Perform automatic sync when coming online
  Future<void> _performAutoSync() async {
    try {
      print('[ConnectivityManager] Starting auto-sync...');

      // Sync farm reports
      final result = await OfflineService.instance.syncPendingReports();

      // Sync other data changes (batches, inventory, etc.)
      await OfflineDataService.instance.syncPendingChanges();

      if (result.success) {
        print('[ConnectivityManager] Auto-sync completed: ${result.message}');
      } else {
        print('[ConnectivityManager] Auto-sync failed: ${result.message}');
      }

      await _updatePendingReportsCount();
    } catch (e) {
      print('[ConnectivityManager] Auto-sync error: $e');
    }
  }

  /// Update pending reports count
  Future<void> _updatePendingReportsCount() async {
    try {
      final count = await OfflineService.instance.getPendingReportsCount();
      pendingReportsNotifier.value = count;
    } catch (e) {
      print('[ConnectivityManager] Error updating pending reports count: $e');
    }
  }

  /// Manually trigger sync
  Future<SyncResult> manualSync() async {
    if (!_isOnline) {
      return SyncResult(
        success: false,
        message: 'Device is offline. Cannot sync reports.',
      );
    }

    try {
      final result = await OfflineService.instance.syncPendingReports();
      await _updatePendingReportsCount();
      return result;
    } catch (e) {
      return SyncResult(success: false, message: 'Sync failed: $e');
    }
  }

  /// Enable or disable auto-sync
  void setAutoSync(bool enabled) {
    _autoSyncEnabled = enabled;
    print(
      '[ConnectivityManager] Auto-sync ${enabled ? 'enabled' : 'disabled'}',
    );
  }

  /// Force refresh connectivity status
  Future<void> refreshConnectivity() async {
    await _checkConnectivity();
    await _updatePendingReportsCount();
  }

  /// Get connectivity status as string
  String getConnectivityStatus() {
    if (_isOnline) {
      return 'Online';
    } else {
      return 'Offline';
    }
  }

  /// Get detailed connectivity info
  Future<Map<String, dynamic>> getConnectivityInfo() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final pendingCount = await OfflineService.instance.getPendingReportsCount();

    return {
      'isOnline': _isOnline,
      'connectivityType': connectivityResult.toString(),
      'autoSyncEnabled': _autoSyncEnabled,
      'pendingReports': pendingCount,
    };
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    isOnlineNotifier.dispose();
    pendingReportsNotifier.dispose();
  }
}

/// Widget to show connectivity status
class ConnectivityStatusWidget extends StatelessWidget {
  final Widget child;
  final bool showOfflineIndicator;

  const ConnectivityStatusWidget({
    super.key,
    required this.child,
    this.showOfflineIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityManager.instance.isOnlineNotifier,
      builder: (context, isOnline, _) {
        return Stack(
          children: [
            child,
            if (!isOnline && showOfflineIndicator)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.orange,
                  child: const Text(
                    'Offline Mode - Reports will sync when online',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Widget to show pending reports count
class PendingReportsIndicator extends StatelessWidget {
  final VoidCallback? onTap;

  const PendingReportsIndicator({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ConnectivityManager.instance.pendingReportsNotifier,
      builder: (context, pendingCount, _) {
        if (pendingCount == 0) return const SizedBox.shrink();

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_upload, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '$pendingCount pending',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

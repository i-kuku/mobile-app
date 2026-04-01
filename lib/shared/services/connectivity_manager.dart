// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'offline_service.dart';
// import 'offline_data_service.dart';

// class ConnectivityManager {
//   static ConnectivityManager? _instance;
//   static ConnectivityManager get instance =>
//       _instance ??= ConnectivityManager._();

//   ConnectivityManager._();

//   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
//   bool _isOnline = false;
//   bool _autoSyncEnabled = true;

//   final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(false);
//   final ValueNotifier<int> pendingReportsNotifier = ValueNotifier<int>(0);

//   bool get isOnline => _isOnline;
//   bool get autoSyncEnabled => _autoSyncEnabled;

//   Future<void> initialize() async {
//     await _checkConnectivity();

//     // Listen for connectivity changes
//     _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
//      List<ConnectivityResult> results,
//     ) async {
//       await _handleConnectivityChange();
//     });

//     // Update pending reports count
//     await _updatePendingReportsCount();

//     debugPrint('[ConnectivityManager] Initialized - Online: $_isOnline');
//   }

//   /// Handle connectivity changes
//   Future<void> _handleConnectivityChange() async {
//     final wasOnline = _isOnline;
//     await _checkConnectivity();

//     if (!wasOnline && _isOnline) {
//       debugPrint('[ConnectivityManager] Device came online');

//       // Auto-sync if enabled
//       if (_autoSyncEnabled) {
//         await _performAutoSync();
//       }
//     } else if (wasOnline && !_isOnline) {
//       debugPrint('[ConnectivityManager] Device went offline');
//     }

//     await _updatePendingReportsCount();
//   }

//   /// Check current connectivity status
//   Future<void> _checkConnectivity() async {
//     try {
//       final connectivityResult = await Connectivity().checkConnectivity();
//       final wasOnline = _isOnline;

//       if (connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty) {
//         _isOnline = false;
//       } else {
//         // Additional check with actual network request
//         _isOnline = await OfflineService.instance.isOnline();
//       }

//       if (wasOnline != _isOnline) {
//         isOnlineNotifier.value = _isOnline;
//       }
//     } catch (e) {
//       debugPrint('[ConnectivityManager] Error checking connectivity: $e');
//       _isOnline = false;
//       isOnlineNotifier.value = false;
//     }
//   }

//   /// Perform automatic sync when coming online
//   Future<void> _performAutoSync() async {
//     try {
//       debugPrint('[ConnectivityManager] Starting auto-sync...');

//       // Sync farm reports
//       final result = await OfflineService.instance.syncPendingReports();

//       // Sync other data changes (batches, inventory, etc.)
//       await OfflineDataService.instance.syncPendingChanges();

//       if (result.success) {
//         debugPrint('[ConnectivityManager] Auto-sync completed: ${result.message}');
//       } else {
//         debugPrint('[ConnectivityManager] Auto-sync failed: ${result.message}');
//       }

//       await _updatePendingReportsCount();
//     } catch (e) {
//       debugPrint('[ConnectivityManager] Auto-sync error: $e');
//     }
//   }

//   /// Update pending reports count
//   Future<void> _updatePendingReportsCount() async {
//     try {
//       final count = await OfflineService.instance.getPendingReportsCount();
//       pendingReportsNotifier.value = count;
//     } catch (e) {
//       debugPrint('[ConnectivityManager] Error updating pending reports count: $e');
//     }
//   }

//   /// Manually trigger sync
//   Future<SyncResult> manualSync() async {
//     if (!_isOnline) {
//       return SyncResult(
//         success: false,
//         message: 'Device is offline. Cannot sync reports.',
//       );
//     }

//     try {
//       final result = await OfflineService.instance.syncPendingReports();
//       await _updatePendingReportsCount();
//       return result;
//     } catch (e) {
//       return SyncResult(success: false, message: 'Sync failed: $e');
//     }
//   }

//   /// Enable or disable auto-sync
//   void setAutoSync(bool enabled) {
//     _autoSyncEnabled = enabled;
//     debugPrint(
//       '[ConnectivityManager] Auto-sync ${enabled ? 'enabled' : 'disabled'}',
//     );
//   }

//   /// Force refresh connectivity status
//   Future<void> refreshConnectivity() async {
//     await _checkConnectivity();
//     await _updatePendingReportsCount();
//   }

//   /// Get connectivity status as string
//   String getConnectivityStatus() {
//     if (_isOnline) {
//       return 'Online';
//     } else {
//       return 'Offline';
//     }
//   }

//   /// Get detailed connectivity info
//   Future<Map<String, dynamic>> getConnectivityInfo() async {
//     final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
//     final pendingCount = await OfflineService.instance.getPendingReportsCount();

//     return {
//       'isOnline': _isOnline,
//       'connectivityType': connectivityResult.toString(),
//       'autoSyncEnabled': _autoSyncEnabled,
//       'pendingReports': pendingCount,
//     };
//   }

//   /// Dispose resources
//   void dispose() {
//     _connectivitySubscription?.cancel();
//     isOnlineNotifier.dispose();
//     pendingReportsNotifier.dispose();
//   }
// }

// /// Widget to show connectivity status


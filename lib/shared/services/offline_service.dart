import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/offline_farm_report.dart';
import 'supabase_service.dart';

class OfflineService {
  static const String _offlineReportsBoxName = 'offline_reports';
  static const String _syncStatusBoxName = 'sync_status';

  static OfflineService? _instance;
  static OfflineService get instance => _instance ??= OfflineService._();

  OfflineService._();

  Box<String>? _offlineReportsBox;
  Box<String>? _syncStatusBox;

  /// Initialize the offline service
  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_offlineReportsBoxName)) {
        _offlineReportsBox = await Hive.openBox<String>(_offlineReportsBoxName);
      } else {
        _offlineReportsBox = Hive.box<String>(_offlineReportsBoxName);
      }

      if (!Hive.isBoxOpen(_syncStatusBoxName)) {
        _syncStatusBox = await Hive.openBox<String>(_syncStatusBoxName);
      } else {
        _syncStatusBox = Hive.box<String>(_syncStatusBoxName);
      }

      print('[OfflineService] Initialized successfully');
    } catch (e) {
      print('[OfflineService] Initialization error: $e');
      rethrow;
    }
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      // TEMPORARY: Force offline mode for testing
      // Uncomment the line below to simulate offline mode
      // return false;

      final connectivityResult = await Connectivity().checkConnectivity();
      print('[OfflineService] Connectivity result: $connectivityResult');

      if (connectivityResult == ConnectivityResult.none) {
        print('[OfflineService] No connectivity detected');
        return false;
      }

      // Additional check by testing Supabase connection
      print('[OfflineService] Testing Supabase connection...');
      final supabaseConnected = await SupabaseService().testConnection();
      print('[OfflineService] Supabase connection result: $supabaseConnected');

      return supabaseConnected;
    } catch (e) {
      print('[OfflineService] Connectivity check error: $e');
      return false;
    }
  }

  /// Save farm report offline
  Future<String> saveFarmReportOffline(Map<String, dynamic> reportData) async {
    try {
      await initialize();

      print(
        '[OfflineService] Attempting to save offline report with data: ${reportData.keys}',
      );

      final reportId = const Uuid().v4();
      final offlineReport = OfflineFarmReport(
        id: reportId,
        reportData: reportData,
        createdAt: DateTime.now(),
      );

      print(
        '[OfflineService] Created offline report object with ID: $reportId',
      );

      if (_offlineReportsBox == null) {
        throw Exception('Offline reports box is null');
      }

      await _offlineReportsBox!.put(reportId, offlineReport.toJson());
      await _setSyncStatus(reportId, 'pending');

      print('[OfflineService] Successfully saved offline report: $reportId');

      // Verify the report was saved
      final savedReport = _offlineReportsBox!.get(reportId);
      if (savedReport == null) {
        throw Exception('Failed to verify saved report');
      }

      print('[OfflineService] Verified report was saved successfully');
      return reportId;
    } catch (e) {
      print('[OfflineService] Error saving offline report: $e');
      rethrow;
    }
  }

  /// Get all pending offline reports
  Future<List<OfflineFarmReport>> getPendingReports() async {
    await initialize();

    final reports = <OfflineFarmReport>[];
    for (final key in _offlineReportsBox!.keys) {
      final status = await _getSyncStatus(key.toString());
      if (status == 'pending') {
        final reportJson = _offlineReportsBox!.get(key);
        if (reportJson != null) {
          try {
            final report = OfflineFarmReport.fromJson(reportJson);
            reports.add(report);
          } catch (e) {
            print('[OfflineService] Error parsing offline report $key: $e');
          }
        }
      }
    }

    // Sort by creation date (oldest first for sync)
    reports.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return reports;
  }

  /// Sync all pending reports to server
  Future<SyncResult> syncPendingReports() async {
    if (!await isOnline()) {
      return SyncResult(success: false, message: 'Device is offline');
    }

    final pendingReports = await getPendingReports();
    if (pendingReports.isEmpty) {
      return SyncResult(success: true, message: 'No reports to sync');
    }

    int successCount = 0;
    int failureCount = 0;
    String? lastError;

    for (final report in pendingReports) {
      try {
        await _setSyncStatus(report.id, 'syncing');

        // Sync the report to Supabase
        await _syncSingleReport(report);

        await _setSyncStatus(report.id, 'synced');
        await _offlineReportsBox!.delete(report.id);
        successCount++;

        print('[OfflineService] Successfully synced report: ${report.id}');
      } catch (e) {
        await _setSyncStatus(report.id, 'failed');
        failureCount++;
        lastError = e.toString();
        print('[OfflineService] Failed to sync report ${report.id}: $e');
      }
    }

    final message =
        'Synced $successCount reports successfully${failureCount > 0 ? ', $failureCount failed' : ''}';

    return SyncResult(
      success: failureCount == 0,
      message: message,
      syncedCount: successCount,
      failedCount: failureCount,
      lastError: lastError,
    );
  }

  /// Sync a single report to the server
  Future<void> _syncSingleReport(OfflineFarmReport offlineReport) async {
    final reportData = offlineReport.reportData;

    // Create daily record first (notes go to batch record, not daily record)
    final dailyRecordData = {
      'user_id': reportData['user_id'],
      'record_date':
          reportData['record_date'] ?? DateTime.now().toIso8601String(),
    };

    final dailyRecordId = await SupabaseService().addDailyRecord(
      dailyRecordData,
    );

    // Create batch record
    final batchRecordData = Map<String, dynamic>.from(reportData);
    batchRecordData['daily_record_id'] = dailyRecordId;
    batchRecordData.remove('user_id'); // Not needed in batch record
    batchRecordData.remove('record_date'); // Not needed in batch record
    // Keep notes in batch record - don't remove it

    // Convert selected materials to the format expected by database
    final feedsData = reportData['selected_feeds'] as List<dynamic>? ?? [];
    final vaccinesData =
        reportData['selected_vaccines'] as List<dynamic>? ?? [];
    final materialsData =
        reportData['selected_other_materials'] as List<dynamic>? ?? [];

    batchRecordData['feeds_used'] = feedsData
        .where((f) => f['quantity'] != null)
        .toList();
    batchRecordData['vaccines_used'] = vaccinesData
        .where((v) => v['quantity'] != null)
        .toList();
    batchRecordData['other_materials_used'] = materialsData
        .where((m) => m['quantity'] != null)
        .toList();

    // Remove the original selected_ fields
    batchRecordData.remove('selected_feeds');
    batchRecordData.remove('selected_vaccines');
    batchRecordData.remove('selected_other_materials');

    await SupabaseService().addBatchRecord(batchRecordData);

    // Update inventory if materials were used
    await _updateInventoryFromReport(reportData);
  }

  /// Update inventory based on materials used in the report
  Future<void> _updateInventoryFromReport(
    Map<String, dynamic> reportData,
  ) async {
    final userId = reportData['user_id'];

    // Update feeds
    final selectedFeeds = reportData['selected_feeds'] as List<dynamic>? ?? [];
    for (final feed in selectedFeeds) {
      if (feed['id'] != null && feed['quantity'] != null) {
        await SupabaseService().updateInventoryQuantity(
          feed['id'],
          -feed['quantity'].toDouble(),
        );
      }
    }

    // Update vaccines
    final selectedVaccines =
        reportData['selected_vaccines'] as List<dynamic>? ?? [];
    for (final vaccine in selectedVaccines) {
      if (vaccine['id'] != null && vaccine['quantity'] != null) {
        await SupabaseService().updateInventoryQuantity(
          vaccine['id'],
          -vaccine['quantity'].toDouble(),
        );
      }
    }

    // Update other materials
    final selectedOtherMaterials =
        reportData['selected_other_materials'] as List<dynamic>? ?? [];
    for (final material in selectedOtherMaterials) {
      if (material['id'] != null && material['quantity'] != null) {
        await SupabaseService().updateInventoryQuantity(
          material['id'],
          -material['quantity'].toDouble(),
        );
      }
    }
  }

  /// Get sync status for a report
  Future<String> _getSyncStatus(String reportId) async {
    await initialize();
    return _syncStatusBox!.get(reportId) ?? 'pending';
  }

  /// Set sync status for a report
  Future<void> _setSyncStatus(String reportId, String status) async {
    await initialize();
    await _syncStatusBox!.put(reportId, status);
  }

  /// Get count of pending reports
  Future<int> getPendingReportsCount() async {
    final pendingReports = await getPendingReports();
    return pendingReports.length;
  }

  /// Clear all synced reports from local storage
  Future<void> clearSyncedReports() async {
    await initialize();

    final keysToDelete = <String>[];
    for (final key in _offlineReportsBox!.keys) {
      final status = await _getSyncStatus(key.toString());
      if (status == 'synced') {
        keysToDelete.add(key.toString());
      }
    }

    for (final key in keysToDelete) {
      await _offlineReportsBox!.delete(key);
      await _syncStatusBox!.delete(key);
    }

    print('[OfflineService] Cleared ${keysToDelete.length} synced reports');
  }

  /// Get all offline reports with their sync status
  Future<List<OfflineReportWithStatus>> getAllOfflineReports() async {
    await initialize();

    final reports = <OfflineReportWithStatus>[];
    for (final key in _offlineReportsBox!.keys) {
      final reportJson = _offlineReportsBox!.get(key);
      final status = await _getSyncStatus(key.toString());

      if (reportJson != null) {
        try {
          final report = OfflineFarmReport.fromJson(reportJson);
          reports.add(OfflineReportWithStatus(report: report, status: status));
        } catch (e) {
          print('[OfflineService] Error parsing offline report $key: $e');
        }
      }
    }

    // Sort by creation date (newest first)
    reports.sort((a, b) => b.report.createdAt.compareTo(a.report.createdAt));
    return reports;
  }
}

/// Result of sync operation
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;
  final String? lastError;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.lastError,
  });
}

/// Offline report with sync status
class OfflineReportWithStatus {
  final OfflineFarmReport report;
  final String status; // 'pending', 'syncing', 'synced', 'failed'

  OfflineReportWithStatus({required this.report, required this.status});
}

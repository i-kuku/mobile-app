import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/supabase_service.dart';
import '../../features/batches/data/batch_model.dart';
import '../../features/inventory/data/inventory_item_model.dart';

class OfflineDataService {
  static const String _batchesBoxName = 'offline_batches';
  static const String _inventoryBoxName = 'offline_inventory';
  static const String _reportsBoxName = 'offline_reports_data';
  static const String _userDataBoxName = 'offline_user_data';
  static const String _lastSyncBoxName = 'last_sync_times';
  
  static OfflineDataService? _instance;
  static OfflineDataService get instance => _instance ??= OfflineDataService._();
  
  OfflineDataService._();
  
  Box<String>? _batchesBox;
  Box<String>? _inventoryBox;
  Box<String>? _reportsBox;
  Box<String>? _userDataBox;
  Box<String>? _lastSyncBox;
  
  /// Initialize all offline data boxes
  Future<void> initialize() async {
    try {
      _batchesBox = await _openBox(_batchesBoxName);
      _inventoryBox = await _openBox(_inventoryBoxName);
      _reportsBox = await _openBox(_reportsBoxName);
      _userDataBox = await _openBox(_userDataBoxName);
      _lastSyncBox = await _openBox(_lastSyncBoxName);
      
      print('[OfflineDataService] All boxes initialized successfully');
    } catch (e) {
      print('[OfflineDataService] Initialization error: $e');
      rethrow;
    }
  }
  
  Future<Box<String>> _openBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<String>(boxName);
    } else {
      return Hive.box<String>(boxName);
    }
  }
  
  /// Cache batches data for offline access
  Future<void> cacheBatches(String userId, List<Map<String, dynamic>> batchesData) async {
    await initialize();
    final dataJson = jsonEncode(batchesData);
    await _batchesBox!.put(userId, dataJson);
    await _setLastSyncTime('batches_$userId');
    print('[OfflineDataService] Cached ${batchesData.length} batches for user $userId');
  }
  
  /// Get cached batches data
  Future<List<Batch>> getCachedBatches(String userId) async {
    await initialize();
    final dataJson = _batchesBox!.get(userId);
    if (dataJson == null) return [];
    
    try {
      final List<dynamic> data = jsonDecode(dataJson);
      return data.map((e) => Batch.fromJson(e)).toList();
    } catch (e) {
      print('[OfflineDataService] Error parsing cached batches: $e');
      return [];
    }
  }
  
  /// Cache inventory data for offline access
  Future<void> cacheInventory(String userId, List<Map<String, dynamic>> inventoryData) async {
    await initialize();
    final dataJson = jsonEncode(inventoryData);
    await _inventoryBox!.put(userId, dataJson);
    await _setLastSyncTime('inventory_$userId');
    print('[OfflineDataService] Cached ${inventoryData.length} inventory items for user $userId');
  }
  
  /// Get cached inventory data
  Future<List<InventoryItem>> getCachedInventory(String userId) async {
    await initialize();
    final dataJson = _inventoryBox!.get(userId);
    if (dataJson == null) return [];
    
    try {
      final List<dynamic> data = jsonDecode(dataJson);
      return data.map((e) => InventoryItem.fromJson(e)).toList();
    } catch (e) {
      print('[OfflineDataService] Error parsing cached inventory: $e');
      return [];
    }
  }
  
  /// Cache reports data for offline access
  Future<void> cacheReports(String userId, List<Map<String, dynamic>> reportsData) async {
    await initialize();
    final dataJson = jsonEncode(reportsData);
    await _reportsBox!.put(userId, dataJson);
    await _setLastSyncTime('reports_$userId');
    print('[OfflineDataService] Cached ${reportsData.length} reports for user $userId');
  }
  
  /// Get cached reports data
  Future<List<Map<String, dynamic>>> getCachedReports(String userId) async {
    await initialize();
    final dataJson = _reportsBox!.get(userId);
    if (dataJson == null) return [];
    
    try {
      final List<dynamic> data = jsonDecode(dataJson);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      print('[OfflineDataService] Error parsing cached reports: $e');
      return [];
    }
  }
  
  /// Cache user dashboard data
  Future<void> cacheUserDashboard(String userId, Map<String, dynamic> dashboardData) async {
    await initialize();
    final dataJson = jsonEncode(dashboardData);
    await _userDataBox!.put('dashboard_$userId', dataJson);
    await _setLastSyncTime('dashboard_$userId');
    print('[OfflineDataService] Cached dashboard data for user $userId');
  }
  
  /// Get cached dashboard data
  Future<Map<String, dynamic>?> getCachedDashboard(String userId) async {
    await initialize();
    final dataJson = _userDataBox!.get('dashboard_$userId');
    if (dataJson == null) return null;
    
    try {
      return jsonDecode(dataJson);
    } catch (e) {
      print('[OfflineDataService] Error parsing cached dashboard: $e');
      return null;
    }
  }
  
  /// Add new batch offline (will sync later)
  Future<void> addBatchOffline(String userId, Map<String, dynamic> batchData) async {
    await initialize();
    
    // Add to pending changes
    final pendingKey = 'pending_batch_${DateTime.now().millisecondsSinceEpoch}';
    final pendingData = {
      'action': 'add',
      'type': 'batch',
      'data': batchData,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _userDataBox!.put(pendingKey, jsonEncode(pendingData));
    
    // Update local cache
    final currentBatches = await getCachedBatches(userId);
    final newBatch = Batch.fromJson(batchData);
    currentBatches.add(newBatch);
    await cacheBatches(userId, currentBatches.map((b) => b.toJson()).toList());
    
    print('[OfflineDataService] Added batch offline: ${batchData['name']}');
  }
  
  /// Add new inventory item offline (will sync later)
  Future<void> addInventoryItemOffline(String userId, Map<String, dynamic> itemData) async {
    await initialize();
    
    // Add to pending changes
    final pendingKey = 'pending_inventory_${DateTime.now().millisecondsSinceEpoch}';
    final pendingData = {
      'action': 'add',
      'type': 'inventory',
      'data': itemData,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _userDataBox!.put(pendingKey, jsonEncode(pendingData));
    
    // Update local cache
    final currentInventory = await getCachedInventory(userId);
    final newItem = InventoryItem.fromJson(itemData);
    currentInventory.add(newItem);
    await cacheInventory(userId, currentInventory.map((i) => i.toJson()).toList());
    
    print('[OfflineDataService] Added inventory item offline: ${itemData['name']}');
  }
  
  /// Get all pending changes that need to be synced
  Future<List<Map<String, dynamic>>> getPendingChanges() async {
    await initialize();
    
    final pendingChanges = <Map<String, dynamic>>[];
    for (final key in _userDataBox!.keys) {
      if (key.toString().startsWith('pending_')) {
        final dataJson = _userDataBox!.get(key);
        if (dataJson != null) {
          try {
            final data = jsonDecode(dataJson);
            data['pendingKey'] = key;
            pendingChanges.add(data);
          } catch (e) {
            print('[OfflineDataService] Error parsing pending change $key: $e');
          }
        }
      }
    }
    
    // Sort by timestamp (oldest first)
    pendingChanges.sort((a, b) => 
        DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));
    
    return pendingChanges;
  }
  
  /// Sync all pending changes to server
  Future<void> syncPendingChanges() async {
    final pendingChanges = await getPendingChanges();
    if (pendingChanges.isEmpty) return;
    
    print('[OfflineDataService] Syncing ${pendingChanges.length} pending changes');
    
    for (final change in pendingChanges) {
      try {
        await _syncSingleChange(change);
        
        // Remove from pending after successful sync
        final pendingKey = change['pendingKey'];
        await _userDataBox!.delete(pendingKey);
        
        print('[OfflineDataService] Synced change: ${change['type']} ${change['action']}');
      } catch (e) {
        print('[OfflineDataService] Failed to sync change: $e');
        // Keep in pending for retry later
      }
    }
  }
  
  /// Sync a single change to the server
  Future<void> _syncSingleChange(Map<String, dynamic> change) async {
    final action = change['action'];
    final type = change['type'];
    final data = change['data'];
    
    switch (type) {
      case 'batch':
        if (action == 'add') {
          await SupabaseService().addBatch(data);
        }
        break;
      case 'inventory':
        if (action == 'add') {
          await SupabaseService().addInventoryItem(data);
        }
        break;
      default:
        print('[OfflineDataService] Unknown change type: $type');
    }
  }
  
  /// Set last sync time for a data type
  Future<void> _setLastSyncTime(String key) async {
    await initialize();
    await _lastSyncBox!.put(key, DateTime.now().toIso8601String());
  }
  
  /// Get last sync time for a data type
  Future<DateTime?> getLastSyncTime(String key) async {
    await initialize();
    final timeStr = _lastSyncBox!.get(key);
    if (timeStr == null) return null;
    
    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if data is stale and needs refresh
  Future<bool> isDataStale(String key, {Duration maxAge = const Duration(hours: 1)}) async {
    final lastSync = await getLastSyncTime(key);
    if (lastSync == null) return true;
    
    return DateTime.now().difference(lastSync) > maxAge;
  }
  
  /// Clear all cached data (useful for logout)
  Future<void> clearAllCache() async {
    await initialize();
    await _batchesBox!.clear();
    await _inventoryBox!.clear();
    await _reportsBox!.clear();
    await _userDataBox!.clear();
    await _lastSyncBox!.clear();
    print('[OfflineDataService] Cleared all cached data');
  }
}

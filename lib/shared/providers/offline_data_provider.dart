import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/offline_data_service.dart';
import '../services/connectivity_manager.dart';
import '../services/supabase_service.dart';
import '../../features/batches/data/batch_model.dart';
import '../../features/inventory/data/inventory_item_model.dart';

class OfflineDataProvider extends ChangeNotifier {
  static OfflineDataProvider? _instance;
  static OfflineDataProvider get instance =>
      _instance ??= OfflineDataProvider._();

  OfflineDataProvider._();

  List<Batch> _batches = [];
  List<InventoryItem> _inventory = [];
  List<Map<String, dynamic>> _reports = [];
  Map<String, dynamic>? _dashboardData;

  bool _batchesLoading = false;
  bool _inventoryLoading = false;
  final bool _reportsLoading = false;
  bool _dashboardLoading = false;

  // Getters
  List<Batch> get batches => _batches;
  List<InventoryItem> get inventory => _inventory;
  List<Map<String, dynamic>> get reports => _reports;
  Map<String, dynamic>? get dashboardData => _dashboardData;

  bool get batchesLoading => _batchesLoading;
  bool get inventoryLoading => _inventoryLoading;
  bool get reportsLoading => _reportsLoading;
  bool get dashboardLoading => _dashboardLoading;

  /// Load batches with offline fallback
  Future<void> loadBatches({bool forceRefresh = false}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _batchesLoading = true;
    notifyListeners();

    try {
      final isOnline = ConnectivityManager.instance.isOnline;
      final isStale = await OfflineDataService.instance.isDataStale(
        'batches_${user.id}',
      );

      if (isOnline && (forceRefresh || isStale)) {
        // Fetch from server and cache
        final data = await SupabaseService().fetchBatches(user.id);
        await OfflineDataService.instance.cacheBatches(user.id, data);
        _batches = data.map((e) => Batch.fromJson(e)).toList();
        print(
          '[OfflineDataProvider] Loaded ${_batches.length} batches from server',
        );
      } else {
        // Load from cache
        _batches = await OfflineDataService.instance.getCachedBatches(user.id);
        print(
          '[OfflineDataProvider] Loaded ${_batches.length} batches from cache',
        );
      }
    } catch (e) {
      print('[OfflineDataProvider] Error loading batches: $e');
      // Fallback to cache on error
      _batches = await OfflineDataService.instance.getCachedBatches(user.id);
    }

    _batchesLoading = false;
    notifyListeners();
  }

  /// Load inventory with offline fallback
  Future<void> loadInventory({bool forceRefresh = false}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _inventoryLoading = true;
    notifyListeners();

    try {
      final isOnline = ConnectivityManager.instance.isOnline;
      final isStale = await OfflineDataService.instance.isDataStale(
        'inventory_${user.id}',
      );

      if (isOnline && (forceRefresh || isStale)) {
        // Fetch from server and cache
        final data = await SupabaseService().fetchInventory(user.id);
        await OfflineDataService.instance.cacheInventory(user.id, data);
        _inventory = data.map((e) => InventoryItem.fromJson(e)).toList();
        print(
          '[OfflineDataProvider] Loaded ${_inventory.length} inventory items from server',
        );
      } else {
        // Load from cache
        _inventory = await OfflineDataService.instance.getCachedInventory(
          user.id,
        );
        print(
          '[OfflineDataProvider] Loaded ${_inventory.length} inventory items from cache',
        );
      }
    } catch (e) {
      print('[OfflineDataProvider] Error loading inventory: $e');
      // Fallback to cache on error
      _inventory = await OfflineDataService.instance.getCachedInventory(
        user.id,
      );
    }

    _inventoryLoading = false;
    notifyListeners();
  }

  /// Load dashboard data with offline fallback
  Future<void> loadDashboardData({bool forceRefresh = false}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _dashboardLoading = true;
    notifyListeners();

    try {
      final isOnline = ConnectivityManager.instance.isOnline;
      final isStale = await OfflineDataService.instance.isDataStale(
        'dashboard_${user.id}',
      );

      if (isOnline && (forceRefresh || isStale)) {
        // Calculate dashboard data from fresh server data
        final batchesData = await SupabaseService().fetchBatches(user.id);
        final inventoryData = await SupabaseService().fetchInventory(user.id);
        final totalEggs = await SupabaseService().fetchTotalEggsCollected(
          user.id,
        );

        int totalBirds = 0;
        int totalFeeds = 0;

        for (final batch in batchesData) {
          final val = batch['total_chickens'] ?? 0;
          totalBirds += val is int ? val : (val is num ? val.toInt() : 0);
        }

        for (final item in inventoryData) {
          if (item['category'] == 'feed') {
            final val = item['quantity'] ?? 0;
            totalFeeds += val is int ? val : (val is num ? val.toInt() : 0);
          }
        }

        // Fetch user's full name from users table
        String userName = 'User';
        try {
          final userResponse = await Supabase.instance.client
              .from('users')
              .select('full_name')
              .eq('id', user.id)
              .maybeSingle();

          final fullName = userResponse?['full_name'] as String?;
          if (fullName != null && fullName.trim().isNotEmpty) {
            userName = fullName.split(' ').first;
          } else {
            // Fallback to email part if no full name
            userName = user.email?.split('@').first ?? 'User';
          }
        } catch (e) {
          // If fetching from users table fails, fallback to email
          userName = user.email?.split('@').first ?? 'User';
        }

        _dashboardData = {
          'totalBirds': totalBirds,
          'totalFeeds': totalFeeds,
          'totalEggs': totalEggs,
          'userName': userName,
        };

        await OfflineDataService.instance.cacheUserDashboard(
          user.id,
          _dashboardData!,
        );
        print('[OfflineDataProvider] Loaded dashboard data from server');
      } else {
        // Load from cache
        _dashboardData = await OfflineDataService.instance.getCachedDashboard(
          user.id,
        );
        print('[OfflineDataProvider] Loaded dashboard data from cache');
      }
    } catch (e) {
      print('[OfflineDataProvider] Error loading dashboard data: $e');
      // Fallback to cache on error
      _dashboardData = await OfflineDataService.instance.getCachedDashboard(
        user.id,
      );
    }

    _dashboardLoading = false;
    notifyListeners();
  }

  /// Add batch (online or offline)
  Future<void> addBatch(Map<String, dynamic> batchData) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final isOnline = ConnectivityManager.instance.isOnline;

    if (isOnline) {
      // Add to server immediately
      await SupabaseService().addBatch(batchData);

      // Create expense record for bird cost
      final batch = Batch.fromJson(batchData);
      final birdCost = batch.pricePerBird * batch.totalChickens;

      if (birdCost > 0) {
        try {
          await SupabaseService().createExpense(
            userId: user.id,
            batchId: batch.id,
            expenseType: 'bird_cost',
            expenseCategory: 'livestock',
            amount: birdCost,
            quantity: batch.totalChickens,
            unitPrice: batch.pricePerBird,
            description: 'Initial purchase cost for batch: ${batch.name}',
            expenseDate: batch.createdAt,
          );
        } catch (e) {
          print('[OfflineDataProvider] Error creating expense record: $e');
          // Don't fail the batch creation if expense tracking fails
        }
      }

      // Refresh local data
      await loadBatches(forceRefresh: true);

      // Update dashboard data to reflect new batch
      final currentDashboardData = _dashboardData ?? {};
      final updatedDashboardData = {
        ...currentDashboardData,
        'totalBirds':
            (currentDashboardData['totalBirds'] ?? 0) + batch.totalChickens,
      };

      await OfflineDataService.instance.cacheUserDashboard(
        user.id,
        updatedDashboardData,
      );
      await loadDashboardData(forceRefresh: true);
    } else {
      // Add offline
      await OfflineDataService.instance.addBatchOffline(user.id, batchData);
      // Update local list immediately for UI
      final newBatch = Batch.fromJson(batchData);
      _batches.add(newBatch);

      // For offline mode, create expense record for bird cost
      final birdCost = newBatch.pricePerBird * newBatch.totalChickens;

      if (birdCost > 0) {
        try {
          await SupabaseService().createExpense(
            userId: user.id,
            batchId: newBatch.id,
            expenseType: 'bird_cost',
            expenseCategory: 'livestock',
            amount: birdCost,
            quantity: newBatch.totalChickens,
            unitPrice: newBatch.pricePerBird,
            description: 'Initial purchase cost for batch: ${newBatch.name}',
            expenseDate: newBatch.createdAt,
          );
        } catch (e) {
          print(
            '[OfflineDataProvider] Error creating expense record (offline mode): $e',
          );
          // Don't fail the batch creation if expense tracking fails
        }
      }

      // Update dashboard data
      final currentDashboardData = _dashboardData ?? {};
      final updatedDashboardData = {
        ...currentDashboardData,
        'totalBirds':
            (currentDashboardData['totalBirds'] ?? 0) + newBatch.totalChickens,
      };
      await OfflineDataService.instance.cacheUserDashboard(
        user.id,
        updatedDashboardData,
      );
      _dashboardData = updatedDashboardData;
      notifyListeners();
    }
  }

  /// Add inventory item (online or offline)
  Future<void> addInventoryItem(Map<String, dynamic> itemData) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final isOnline = ConnectivityManager.instance.isOnline;

    if (isOnline) {
      // Add to server immediately
      await SupabaseService().addInventoryItem(itemData);
      // Refresh local data
      await loadInventory(forceRefresh: true);

      // Update dashboard data for feeds
      if (itemData['category'] == 'feed') {
        final currentDashboardData = _dashboardData ?? {};
        final updatedDashboardData = {
          ...currentDashboardData,
          'totalFeeds':
              (currentDashboardData['totalFeeds'] ?? 0) +
              (itemData['quantity'] as num).toDouble(),
        };

        await OfflineDataService.instance.cacheUserDashboard(
          user.id,
          updatedDashboardData,
        );
        await loadDashboardData(forceRefresh: true);
      }
    } else {
      // Add offline
      await OfflineDataService.instance.addInventoryItemOffline(
        user.id,
        itemData,
      );
      // Update local list immediately for UI
      final newItem = InventoryItem.fromJson(itemData);
      _inventory.add(newItem);

      // Update dashboard data for feeds
      if (newItem.category == 'feed') {
        final currentDashboardData = _dashboardData ?? {};
        final updatedDashboardData = {
          ...currentDashboardData,
          'totalFeeds':
              (currentDashboardData['totalFeeds'] ?? 0) + newItem.quantity,
        };
        await OfflineDataService.instance.cacheUserDashboard(
          user.id,
          updatedDashboardData,
        );
        _dashboardData = updatedDashboardData;
      }
      notifyListeners();
    }
  }

  /// Get inventory items by category
  List<InventoryItem> getInventoryByCategory(String category) {
    return _inventory.where((item) => item.category == category).toList();
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([
      loadBatches(forceRefresh: true),
      loadInventory(forceRefresh: true),
      loadDashboardData(forceRefresh: true),
    ]);
  }

  /// Cache reports data directly
  Future<void> cacheReports(
    String userId,
    List<Map<String, dynamic>> reportsData,
  ) async {
    await OfflineDataService.instance.cacheReports(userId, reportsData);
    _reports = reportsData;
    notifyListeners();
  }

  /// Cache batches data directly
  Future<void> cacheBatches(
    String userId,
    List<Map<String, dynamic>> batchesData,
  ) async {
    await OfflineDataService.instance.cacheBatches(userId, batchesData);
    _batches = batchesData.map((e) => Batch.fromJson(e)).toList();
    notifyListeners();
  }

  /// Cache inventory data directly
  Future<void> cacheInventory(
    String userId,
    List<Map<String, dynamic>> inventoryData,
  ) async {
    await OfflineDataService.instance.cacheInventory(userId, inventoryData);
    _inventory = inventoryData.map((e) => InventoryItem.fromJson(e)).toList();
    notifyListeners();
  }

  /// Get cached reports data
  Future<List<Map<String, dynamic>>> getCachedReports(String userId) async {
    return await OfflineDataService.instance.getCachedReports(userId);
  }

  /// Clear all data (useful for logout)
  void clearAllData() {
    _batches.clear();
    _inventory.clear();
    _reports.clear();
    _dashboardData = null;
    notifyListeners();
  }
}

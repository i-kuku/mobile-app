import 'package:flutter/material.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryProvider extends ChangeNotifier {
  final List<InventoryItem> _inventory = [];
  bool _isloading = false;

  List<InventoryItem> get inventory => _inventory;
  bool get isloading => _isloading;

  List<InventoryItem> get feeds =>
      _inventory.where((item) => item.category == 'feeds').toList();

  List<InventoryItem> get medicines =>
      _inventory.where((item) => item.category == 'medicines').toList();

  List<InventoryItem> get others =>
      _inventory.where((item) => item.category == 'others').toList();

  ///Fetches all inventory items for a logged in user
  Future<void> fetchInventory() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _isloading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('inventory_items')
          .select()
          .eq('user_id', userId)
          .order('added_on', ascending: false);

      _inventory.clear();
      for (final json in response) {
        _inventory.add(InventoryItem.fromJson(json));
      }
    } catch (e) {
      debugPrint('Error fetching inventory: $e');
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    try {
      await Supabase.instance.client
          .from('inventory_items')
          .insert(item.toJson());

      _inventory.add(item);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding inventory item: $e');
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    try {
      await Supabase.instance.client
          .from('inventory_items')
          .delete()
          .eq('id', id);

      _inventory.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting inventory item: $e');
    }
  }

  Future<void> incrementQuantity(String id, int amount) async {
    final index = _inventory.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final currentItem = _inventory[index];
    final newQuantity = currentItem.quantity + amount;

    try {
      await Supabase.instance.client
          .from('inventory_items')
          .update({'quantity': newQuantity})
          .eq('id', id);

      _inventory[index] = InventoryItem(
        daily_records_id: currentItem.daily_records_id,
        id: currentItem.id,
        userId: currentItem.userId,
        name: currentItem.name,
        quantity: newQuantity,
        unit: currentItem.unit,
        price: currentItem.price,
        category: currentItem.category,
        addedOn: currentItem.addedOn,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Error incrementing quantity: $e");
    }
  }

  void clearInventory() {
    _inventory.clear();
    notifyListeners();
  }

  /// Update an item's details on Supabase and sync local state
  Future<void> updateInventoryItem(InventoryItem updatedItem) async {
    try {
      // 1. Update the row inside your Supabase table matching the item ID
      await Supabase.instance.client
          .from('inventory_items')
          .update(updatedItem.toJson())
          .eq('id', updatedItem.id);

      // 2. Only if the network request succeeds, update our local memory list
      final index = _inventory.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _inventory[index] = updatedItem;
        notifyListeners(); // Refresh the UI screens immediately
      }

      debugPrint("Successfully updated inventory item in Supabase.");
    } catch (e) {
      debugPrint("Error updating inventory item: $e");
    }
  }
}

import 'package:flutter/material.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';


class InventoryProvider extends ChangeNotifier {
  final List<InventoryItem> _inventory = [];
  final bool _isloading = false;

  List<InventoryItem> get inventory => _inventory;
  bool get isloading => _isloading;

  List<InventoryItem> get feeds => 
      _inventory.where((item) => item.category == 'feeds').toList();
      
  List<InventoryItem> get medicines => 
      _inventory.where((item) => item.category == 'medicines').toList();
      
  List<InventoryItem> get others => 
      _inventory.where((item) => item.category == 'others').toList();

  void addInventoryItem(InventoryItem item) {
    _inventory.add(item);
    notifyListeners();
  }

  void removeInventoryItem(String id) {
    _inventory.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearInventory() {
    _inventory.clear();
    notifyListeners();
  }
  void updateInventoryItem(InventoryItem updatedItem){
    final index=_inventory.indexWhere((item)=> item.id ==updatedItem.id);
    if(index != -1){
    _inventory[index]=updatedItem;
    notifyListeners();
    }
  }
  void incrementQuantity(String id) {
    final index = _inventory.indexWhere((item) => item.id == id);
    if (index != -1) {
      final currentItem = _inventory[index];
      
      _inventory[index] = InventoryItem(
        id: currentItem.id,
        name: currentItem.name,
        quantity: currentItem.quantity + 1,
        unit: currentItem.unit,
        price: currentItem.price,
        category: currentItem.category,
      );
      
      notifyListeners();
    }
  }
}
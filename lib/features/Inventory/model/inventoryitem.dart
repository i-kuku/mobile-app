class InventoryItem {
  final String id;
  final String userId;
  final String name;
  final int quantity;
  final String unit;
  final double price;
  final String category;
  final DateTime addedOn;
  final String daily_records_id;

  InventoryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.category,
    required this.addedOn,
    required this.daily_records_id,
  });
  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    daily_records_id: json['daily_records_id'] as String,
    quantity: json['quantity'] as int,
    unit: json['unit'] as String,
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    addedOn: DateTime.parse(json['added_on'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'category': category,
    'daily_records_id': daily_records_id,
    'quantity': quantity,
    'unit': unit,
    'price': price,
    'added_on': addedOn.toIso8601String(),
  };

}

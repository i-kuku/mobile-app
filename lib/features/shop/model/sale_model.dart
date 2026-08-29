class SaleModel {
  final String? id;
  final String saleType;
  final String? subType;
  final int quantity;
  final double amount;
  final DateTime createdAt;

  SaleModel({
    this.id,
    required this.saleType, 
    this.subType, 
    required this.quantity, 
    required this.amount, 
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

 String get displayTitle {
    final type = saleType.toLowerCase();
    
    if (type == 'chicken') {
      final cleanSubType = subType?.trim();
      final formattedType = cleanSubType != null && cleanSubType.isNotEmpty
          ? '${cleanSubType[0].toUpperCase()}${cleanSubType.substring(1).toLowerCase()} '
          : '';
      return '$quantity ${formattedType}Chicken';
    } else if (type == 'eggs') {
      return '$quantity Eggs';
    } else if (type == 'manure') {
      return '$quantity ${quantity == 1 ? 'Bag' : 'Bags'} Manure';
    }
    return '$quantity Items';
  }

  factory SaleModel.fromJson(Map<String, dynamic> json){
    return SaleModel(
      id:json['id'] as String?,
      saleType:json['sale_type'] ?? 'chicken',
      subType:json['sub_type'],
      quantity: (json['quantity'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String,dynamic> toJson(){
    return{
      if (id != null) 'id': id,
      'sale_type': saleType,
      'sub_type':subType,
      'quantity': quantity,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
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
    final type = saleType.toLowerCase().replaceAll('"', '').trim();
    final cleanSubType = subType?.replaceAll('"', '').trim();

    if (type == 'chicken') {
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

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      // Converts int8 (e.g. 6, 7) or String IDs safely without throwing
      id: json['id']?.toString(),
      // Clean up string quotes if saved as JSONB strings
      saleType: (json['sale_type']?.toString() ?? 'chicken').replaceAll('"', ''),
      subType: json['sub_type']?.toString().replaceAll('"', ''),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString()).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'sale_type': saleType,
      'sub_type': subType,
      'quantity': quantity,
      'amount': amount,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
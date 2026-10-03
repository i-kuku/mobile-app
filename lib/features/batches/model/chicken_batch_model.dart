class ChickenBatch {
  final String id;
  final String name;
  final String typeOfBird;
  final int initialCount;
  final int age;
  final String ageUnit;
  final DateTime createdAt;
  final num purchaseCost;

  ChickenBatch({
    required this.id,
    required this.name,
    required this.typeOfBird,
    required this.initialCount,
    required this.age,
    required this.ageUnit,
    required this.createdAt,
    this.purchaseCost = 0,
  });

  factory ChickenBatch.fromJson(Map<String, dynamic> json) {
    return ChickenBatch(
      id: json['id'] as String,
      name: json['name'] as String,
      typeOfBird: json['type_of_bird'] as String,
      initialCount: json['initial_count'] as int,
      age: json['age'] as int,
      ageUnit: json['age_unit'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      purchaseCost: (json['purchase_cost'] as num?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type_of_bird': typeOfBird,
      'initial_count': initialCount,
      'age': age,
      'age_unit': ageUnit,
      'created_at': createdAt.toIso8601String(),
      'purchase_cost': purchaseCost,
    };
  }
}
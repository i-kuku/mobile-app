class ChickenBatch{
  final String id;
  final String name;
  final String typeOfBird;
  final int initialNumberOfBirds;
  final int currentNumberOfBirds;
  final int age;
  final String ageUnit;
  final DateTime createdAt;

  ChickenBatch({
    required this.id,
    required this.name,
    required this.typeOfBird,
    required this.initialNumberOfBirds,
    required this.currentNumberOfBirds,
    required this.age,
    required this.ageUnit,
    required this.createdAt, 
  });
  factory ChickenBatch.fromJson(Map<String, dynamic> json) => ChickenBatch(
    id: json['id'] as String,
    name: json['name'] as String,
    typeOfBird: json['type_of_bird'] as String,
    initialNumberOfBirds: json['initial_number_of_birds'] as int,
    currentNumberOfBirds: json['current_number_of_birds'] as int,
    age: json['age'] as int,
    ageUnit: json['age_unit'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
   Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type_of_bird':typeOfBird,
    'initial_number_of_birds':initialNumberOfBirds,
    'current_number_of_birds':currentNumberOfBirds,
    'age':age,
    'age_unit':ageUnit,
    'created_at':createdAt.toIso8601String(),
  };
}
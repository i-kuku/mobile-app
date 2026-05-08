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
}
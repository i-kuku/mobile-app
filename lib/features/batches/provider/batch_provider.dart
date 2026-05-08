import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:uuid/uuid.dart';

class BatchProvider extends ChangeNotifier{
  final List<ChickenBatch> _batches=[];

  List <ChickenBatch> get batches => _batches;

  void addBatch({
    required String name,
    required String typeOfBird,
    required int initialCount,
    required int age,
    required String ageUnit,
  }){
    final newBatch=ChickenBatch(
      id: const Uuid().v4(), 
      name: name, 
      typeOfBird: typeOfBird, 
      initialNumberOfBirds: initialCount, 
      currentNumberOfBirds: initialCount, 
      age: age, 
      ageUnit: ageUnit, 
      createdAt: DateTime.now(),
      );

      _batches.add(newBatch);
      notifyListeners();
      // tells the ui to rebuild and show the new batch.
  }
  // function to remove a batch
  void removeBatch(String id){
    _batches.removeWhere((batch)=>batch.id==id);
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';

class BatchProvider extends ChangeNotifier{
  // final SupabaseClient _supabase = Supabase.instance.client;
  final List<ChickenBatch> _batches=[];
  // bool _isLoading = false;

  List <ChickenBatch> get batches => _batches;
  // bool get _isLoading => _isLoading;

 Future<void> fetchBatches() async {
  // _isLoading = true;
  notifyListeners();

  try{
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if(userId == null) return;

    final response = await Supabase.instance.client
    .from('batches')
    .select()
    .eq('user_id',userId)
    .order('created_at',ascending: false);

  _batches.clear();
  for(var item in response){
    _batches.add(ChickenBatch.fromJson(item));
  }
  }catch(e){
    debugPrint('Error fetching batches: $e');
  }finally{
    // _isLoading = false;
    notifyListeners();
  }
 }



 Future<void> addBatch({
    required String name,
    required String typeOfBird,
    required int initialCount,
    required int age,
    required String ageUnit,
  }) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final newBatchData = {
        'user_id': userId,
        'name': name,
        'type_of_bird': typeOfBird,
        'initial_count': initialCount,
        'age': age,
        'age_unit': ageUnit,
      };

      await Supabase.instance.client
          .from('batches')
          .insert(newBatchData);
          
          await fetchBatches();
    } catch (e) {
      debugPrint('Error inserting batch: $e');
      rethrow; 
    }
  }

  Future<void> updateBatch({
    required String id,
    required String name,
    required String typeOfBird,
    required int initialCount,
    required int age,
    required String ageUnit,
  }) async {
    try {
      final updatedData = {
        'name': name,
        'type_of_bird': typeOfBird,
        'initial_count': initialCount,
        'age': age,
        'age_unit': ageUnit,
      };

      await Supabase.instance.client
      .from('batches')
      .update(updatedData)
      .eq('id', id);

      final index = _batches.indexWhere((element) => element.id == id);
      if (index != -1) {
        _batches[index] = ChickenBatch(
          id: id,
          name: name,
          typeOfBird: typeOfBird,
          initialCount: initialCount,
          age: age,
          ageUnit: ageUnit,
          createdAt: _batches[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating batch: $e');
      rethrow;
    }
  }

  Future<void> removeBatch(String id) async{
    try{
      await Supabase.instance.client
      .from('batches')
      .delete()
      .eq('id',id);
      _batches.removeWhere((batch) => batch.id == id);
      notifyListeners();
    }catch(e){
      debugPrint('Error deleting batch $e');
    }
  }
}
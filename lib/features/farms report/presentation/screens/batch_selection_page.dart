import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/farms%20report/widgets/batch_card.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class BatchSelectionPage extends StatefulWidget {
  const BatchSelectionPage({super.key});

  @override
  State<BatchSelectionPage> createState() => _BatchSelectionPageState();
}

class _BatchSelectionPageState extends State<BatchSelectionPage> {
  late Future<List<ChickenBatch>> _batchesFuture;

  @override
   void initState(){
    super.initState();
    _batchesFuture = _fetchUserBatches();
   }
   
   Future<List<ChickenBatch>>_fetchUserBatches() async{
final session = Supabase.instance.client.auth.currentSession;

if (session == null) {
  
  debugPrint('User is not logged in. Redirect to login screen.');
  return[];
} 
final response = await Supabase.instance.client
      .from('batches')
      .select()
      .order('created_at', ascending: false); 

final List<dynamic> data = response;
 return data.map((json)=>ChickenBatch.fromJson
 (json as Map<String,dynamic>)).toList();
    
   }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back,color: CustomColors.primary,),
        title: Text("farm_reports_entry".tr(),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16,color:CustomColors.primary),
        ),
      ),
      body:SafeArea(
        child: Column(
           children: [
            Text("select_batch_message".tr(),style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: CustomColors.text,fontSize: 16),),
            FutureBuilder<List<ChickenBatch>>(
              future: _batchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading batches: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No active batches found.'),
            );
          }

          final batches = snapshot.data!;
          return ListView.builder(
            itemCount: batches.length,
            itemBuilder: (context, index){
              final batch = batches[index];
              return BatchCard(
                batch: batch
                );
            }
            );
        }
            )
           ],
        )
      )
    );
  }
}
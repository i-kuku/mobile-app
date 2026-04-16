import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/presentation/Widgets/batch_card.dart';
import 'package:ikuku/features/batches/presentation/create_batch_page.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:provider/provider.dart';

class ManageBatchPage extends StatelessWidget {
  const ManageBatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black), 
          onPressed: () =>Navigator.pop(context),
        ),
        title: Text("Batches",style:TextStyle(color: Colors.black),),
        actions: [
          IconButton(onPressed: () { }, 
          icon: Icon(Icons.notification_add_outlined,color: Colors.black),),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              "Manage Batches",
              style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Align(
                alignment:Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const CreateBatchPage()),);
                  },
                  icon:Icon(Icons.add_circle,color:Colors.green,size:20), 
                  label:Text(
                    "Add New Batch",
                    style:TextStyle(color:Colors.black,fontWeight: FontWeight.w500),
                    ),
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<BatchProvider>(
                  builder: (context, provider, child) {
                    if(provider.batches.isEmpty){
                      return const Center(child: Text("No Batches yet.Add one!"),);
                    }
                    return ListView.builder(
                      itemCount:provider.batches.length,
                      itemBuilder: (context, index) {
                        final batch=provider.batches[index];
                        return BatchCard(
                          batch: batch, 
                          onEdit: () {
                            debugPrint("Edit  tapped for ${batch.name}");
                          }, 
                          onDelete: () {
                            debugPrint("Delete tapped for ${batch.name}");
                          },);
                      },);
                },)
                )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/batches/presentation/Widgets/batch_card.dart';
// import 'package:ikuku/features/batches/presentation/screens/create_batch_page.dart';
import 'package:ikuku/features/batches/presentation/widgets/pop_up.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ManageBatchPage extends StatelessWidget {
  const ManageBatchPage({super.key});

  void _handleremovebatchsequence(BuildContext context, ChickenBatch batch) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopUp(
        icon: Icon(Icons.error_outline_outlined),
        messagebefore: "Are you sure you want to \nremove this batch?",
        mainButtonText: "YES,I'M SURE",
        secondaryButtonText: "CANCEL",
        onMainAction: () {
          Navigator.pop(context);
          _showsuccessRemoved(context, batch);
        },
      ),
    );
  }

  void _showsuccessRemoved(BuildContext context, ChickenBatch batch) {
    showDialog(
      context: context,
      builder: (context) => PopUp(
        icon: Image.asset('assets/images/farmer.svg'),
        batchName: batch.name,
        messageAfter: "has been removed",
        mainButtonText: 'null',
      ),
    );
    Future.delayed(Duration(milliseconds: 1500), () {
      if (context.mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Batches", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child:
            Expanded(
              child: Consumer<BatchProvider>(
                builder: (context, provider, child) {
                  if (provider.batches.isEmpty) {
                    return _buildEmptyState(context);
                  }
                 else{
                  return _buildActiveState(context, provider);
                 }
                },
              ),
            ),
      ),
      );
  }

Widget _buildEmptyState(BuildContext context){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              "Manage Batches",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Image.asset('assets/icons/tip-chicken.png'),
                  SizedBox(width: 10),
                  Text(
                    "Tip:A batch is a group of chicken,\n obtained at the same time",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text("My Batches", style: TextStyle(color: CustomColors.text)),
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Image.asset('assets/icons/add-batch.svg', width: 150),
                  Text("You have no batches yet"),
                  Text('The batches You Create will appear here'),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.push('/create_batch_page');
                    },
                    child: Text("CREATE A BATCH"),
                  ),
                ],
              ),
            ),
          ],
       );
}
Widget _buildActiveState(BuildContext context,BatchProvider provider){
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              "Manage Batches",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => context.push('/create_batch_page'),
                   icon: Icon(Icons.add_circle,color: CustomColors.primary),
                   ),
                  Text("Add New Batch"),
              ],
            ),
            SizedBox(height:10),
                Expanded(
              child:ListView.builder(
                    itemCount: provider.batches.length,
                    itemBuilder: (context, index) {
                      final batch = provider.batches[index];
                      return BatchCard(
                        batch: batch,
                        onEdit: () {
                          context.push('/edit_batch_page', extra: batch);
                        },
                        onDelete: () {
                          _handleremovebatchsequence(context, batch);
                        },
                      );
                    },
              ),
            ),
          ],
      );
}
}


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
        title: Text("Batches", style: Theme.of(context).textTheme.titleLarge!.copyWith(color: CustomColors.text)),
        centerTitle: true,
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
            const SizedBox(height: 24),
            Text(
              "Manage Batches",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: CustomColors.text,fontSize: 30),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Image.asset('assets/icons/tip-chicken.png',height: 50,width: 49.03),
                  SizedBox(width: 10),
                  Text(
                    "Tip:A batch is a group of chicken,\n obtained at the same time",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: CustomColors.textDisabled),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text("My Batches", style: Theme.of(context).textTheme.titleLarge!.copyWith(color: CustomColors.text)),
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Image.asset('assets/icons/amico.png', width: 130,height: 130),
                  Text("You have no batches yet",style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: CustomColors.textDisabled,fontWeight:FontWeight.w400,fontSize:16)),
                  Text('The batches You create will appear here',style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: CustomColors.textDisabled)),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.push('/create_batch_page');
                    },
                    child: Text("CREATE A BATCH", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: CustomColors.primary,fontSize: 16,fontFamily: 'Roboto',decoration: TextDecoration.underline)),
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
              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: CustomColors.text),
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


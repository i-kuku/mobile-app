import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/batches/presentation/widgets/pop_up.dart';
import 'package:ikuku/theme/app_theme.dart';

class ConfirmBatchPage extends StatelessWidget {
  final Map<String, dynamic> batchData;

  const ConfirmBatchPage({super.key, required this.batchData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => context.pop(),

          child: Row(
            children: [
              SizedBox(width: 8),
              Icon(Icons.arrow_back, size: 18, color: Colors.black),
              SizedBox(width: 4),
              Text("Back", style: TextStyle(color: Colors.black, fontSize: 16)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                height: 46,
                width: double.infinity,
                decoration: BoxDecoration(color: CustomColors.lightYellow),
                child: Text("Confirm Your Batch"),
              ),
              SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 3,
                children: [
                  _gridItem("Batch Name", batchData['name']),
                  _gridItem("Type of Bird", batchData['typeOfBird']),
                  _gridItem("Number of Birds", batchData['initialCount']),
                  _gridItem(
                    "Age",
                    "${batchData['age']} ${batchData['ageUnit']}",
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.push('/edit_batch', extra: batchData);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: CustomColors.primary),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Edit",
                        style: TextStyle(color: CustomColors.primary),
                      ),
                    ),
                  ),

                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => PopUp(
                            icon: Image.asset(
                              "assets/icons/add-batch",
                              height: 120,
                            ),
                            batchName: batchData['name'],
                            messageAfter: "has been created successfully",
                            mainButtonText: null,
                          ),
                        );
                        Future.delayed(Duration(milliseconds: 1500), () {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            context.go('/batches');
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "confirm",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _gridItem(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        label,
        style: TextStyle(color: CustomColors.textColorSecondary, fontSize: 14),
      ),
      Text(
        value,
        style: TextStyle(
          color: CustomColors.text,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ],
  );
}

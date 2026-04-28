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
        elevation: 0,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => context.pop(),

          child: Row(
            children: [
              SizedBox(width: 8),
              Icon(Icons.arrow_back, size: 18, color: Colors.black),
              SizedBox(width: 4),
              Text("Back", style: TextStyle(color: CustomColors.text, fontSize: 16,fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(height: 24),
              Container(
                height: 46,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 8),
                decoration: BoxDecoration(color: CustomColors.secondary),
                child: Text("Confirm Your Batch",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: CustomColors.text
                ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _listItem("Batch Name", batchData['name']),
                    _listItem("Type Of Bird", batchData['typeOfBird']),
                    _listItem("Number Of Birds", batchData['initialCount']),
                    _listItem(
                      "Age",
                      "${batchData['age']} ${batchData['ageUnit']}",
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/edit_batch_page', extra: batchData);
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: CustomColors.secondary),
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(1),
                        // ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        
                      ),
                      child: Text(
                        "Edit",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: CustomColors.primary,),
                      ),
                    ),
                  ),
                  SizedBox(width: 58),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => PopUp(
                            icon: Image.asset(
                              "assets/icons/tip-chicken.png",
                              height: 110,
                              width: 50,
                              fit: BoxFit.contain,
                            ),
                            messagebefore: "You have created\t",
                             batchName: batchData['name'],
                            mainButtonText: null,
                          ),
                        );
                        Future.delayed(Duration(milliseconds: 500), () {
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
                        "Confirm",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
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

Widget _listItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: CustomColors.textColorSecondary, fontSize: 20),
        ),
        Text(
          value,
          style: TextStyle(
            color: CustomColors.text,
            fontWeight: FontWeight.w400,
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}

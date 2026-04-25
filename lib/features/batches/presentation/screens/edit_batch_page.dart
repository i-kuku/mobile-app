import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';
// import 'package:provider/provider.dart';

class EditBatchPage extends StatefulWidget {
  const EditBatchPage({super.key});

  @override
  State<EditBatchPage> createState() => _EditBatchPageState();
}

class _EditBatchPageState extends State<EditBatchPage> {
  final _formKey=GlobalKey<FormState>();

  final _nameController=TextEditingController();
  final _countController=TextEditingController();
  final _ageController=TextEditingController();

  String _selectedType='Layers';
  String _selectedUnit='Days';
  
  @override
  void dispose(){
    _nameController.dispose();
    _countController.dispose();
     _ageController.dispose();
     super.dispose();
  }

  void _saveBatch(){
    if(_formKey.currentState!.validate()){
        
        final batchData={
          'name':_nameController.text,
          'typeOfBird':_selectedType,
          'initialCount':_countController.text,
          'age':_ageController.text,
          'ageUnit':_selectedUnit,
        };
        context.push('/confirm-batch',extra: batchData);
      // context.read<BatchProvider>().addBatch(
      //   name:_nameController.text,
      //   typeOfBird:_selectedType,
      //   initialCount:int.parse(_countController.text),
      //   age:int.parse(_ageController.text),
      //   ageUnit:_selectedUnit,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        elevation: 0,
        leadingWidth: 100,
        leading: InkWell(
    onTap: () => context.pop(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_back,
          color: Colors.black,
          size: 18,
        ),
        const SizedBox(width: 4),
        const Text(
          "Back",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
        ),
        
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Form(
              key:_formKey,
              child:ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(8),
                children: [
                  SizedBox(height: 12),
                  Text("Create New Batch",
                  style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 48),
                  Text("Batch Name"),
                  TextFormField(
                    controller:_nameController,
                    decoration: InputDecoration(
                      hintText: "batch 1",
                      border:UnderlineInputBorder(
                        borderSide:BorderSide(color:CustomColors.textDisabled),
                      ),
                      enabledBorder:UnderlineInputBorder(
                        borderSide:BorderSide(color:CustomColors.textDisabled)
                      ),
                      focusedBorder:UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.primary,width:2)
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.zero,
                      ),
                    validator: (value) => value!.isEmpty ? "Enter a name" : null,
                    ),
                    SizedBox(height:48),
            
                    Row(
                      children: [
                        Expanded(
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Type Of Bird"),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                   border:UnderlineInputBorder(
                                     borderSide:BorderSide(color:CustomColors.textDisabled),
                                       ),
                                      enabledBorder:UnderlineInputBorder(
                                     borderSide:BorderSide(color:CustomColors.textDisabled)
                                       ),
                                      focusedBorder:UnderlineInputBorder(
                                       borderSide: BorderSide(color: CustomColors.primary,width:2)
                                          ),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                           contentPadding: EdgeInsets.zero,
                                ),
                                initialValue:_selectedType,
                                items:['Layers','Broilers'].map((type){
                                  return DropdownMenuItem(value:type,child:Text(type));
                                }).toList(),
                                onChanged: (val)=>setState(() =>_selectedType=val!),
                              ),
                            ],
                          ),
                        ),
                              SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    const Text("Number of Birds"),
                                    TextFormField(
                                      controller: _countController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText:"0",
                                         border:UnderlineInputBorder(
                                            borderSide:BorderSide(color:CustomColors.textDisabled),
                                                 ),
                                          enabledBorder:UnderlineInputBorder(
                                        borderSide:BorderSide(color:CustomColors.textDisabled)
                                     ),
                                    focusedBorder:UnderlineInputBorder(
                                       borderSide: BorderSide(color: CustomColors.primary,width:2)
                                        ),
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                        contentPadding: EdgeInsets.zero,
                                        ),
                                    ),
                                  ],
                                )
                                )
            
                            ],
                          ), 
                 SizedBox(height: 48),
                 Row(
                  children: [
                    Expanded(
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Age"),
                          TextFormField(
                            controller:_ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "3",
                               border:UnderlineInputBorder(
                        borderSide:BorderSide(color:CustomColors.textDisabled),
                      ),
                      enabledBorder:UnderlineInputBorder(
                        borderSide:BorderSide(color:CustomColors.textDisabled)
                      ),
                      focusedBorder:UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.primary,width:2)
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.zero,
                              ),
                          ),
                        ],
                      ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Days/Weeks/Months"),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedUnit,
                              decoration: InputDecoration(
                                 border:UnderlineInputBorder(
                                  borderSide:BorderSide(color:CustomColors.textDisabled),
                                    ),
                                  enabledBorder:UnderlineInputBorder(
                                    borderSide:BorderSide(color:CustomColors.textDisabled)
                                      ),
                                    focusedBorder:UnderlineInputBorder(
                                      borderSide: BorderSide(color: CustomColors.primary,width:2)
                                      ),
                                     floatingLabelBehavior: FloatingLabelBehavior.always,
                                       contentPadding: EdgeInsets.zero,
                              ),
                              items: ['Days','Weeks','Months'].map((unit){
                                return DropdownMenuItem(value:unit,child: Text(unit));
                              }).toList(),
                              onChanged: (val)=>setState(()=>_selectedUnit=val!),
                            ),
                          ],
                        )),
                  ],
                 ),
                 SizedBox(height: 48),
                  FeatureButton(
                    label: "Update", 
                    icon: Icons.add, 
                    onTap:_saveBatch,
                    ),
                ],
            
              )
              ),
          ),
        ),
        

    );
  }
}
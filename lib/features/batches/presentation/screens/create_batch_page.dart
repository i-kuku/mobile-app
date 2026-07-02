import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';

class CreateBatchPage extends StatefulWidget {
  const CreateBatchPage({super.key});

  @override
  State<CreateBatchPage> createState() => _CreateBatchPageState();
}

class _CreateBatchPageState extends State<CreateBatchPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _countController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedType = "layer";
  String _selectedUnit = "Days";

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _saveBatch() {
    if (_formKey.currentState!.validate()) {
      final batchData = {
        'name': _nameController.text,
        'typeOfBird': _selectedType,
        'initialCount': _countController.text,
        'age': _ageController.text,
        'ageUnit': _selectedUnit,
      };
      context.push('/confirm_batch_page', extra: batchData);
    }
  }

  Widget _buildLabelField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: CustomColors.text,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: field),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => context.pop(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back, color: Colors.black, size: 18),
              const SizedBox(width: 4),
               Text(
                'Back'.tr(),
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
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(8),
              children: [
                SizedBox(height: 12),
                Text(
                  "create_new_batch".tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: CustomColors.text),
                ),
                SizedBox(height: 48),
                Text(
                  "Batch_Name".tr(),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: CustomColors.text,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: "batch_1".tr()),
                  validator: (value) => value!.isEmpty ? "enter_a_name".tr() : null,
                ),
                SizedBox(height: 48),

                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.8,
                  crossAxisCount: 2,
                  children: [
                    _buildLabelField(
                      "type_of_bird".tr(),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        items: ["layer", "broiler"].map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.tr()),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedType = val!),
                      ),
                    ),
                    _buildLabelField(
                      "number_of_birds".tr(),
                      TextFormField(
                        controller: _countController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "0"),
                        validator: (value) =>
                            value!.isEmpty ? "enter_a_number".tr() : null,
                      ),
                    ),
                    _buildLabelField(
                      "Age".tr(),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "3"),
                        validator: (value) =>
                            value!.isEmpty ? "enter_the_age".tr() : null,
                      ),
                    ),

                    _buildLabelField(
                      "age_unit".tr(),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedUnit,
                        items: ["Days", "Weeks", "Months"].map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit.tr()),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedUnit = val!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 48),
                FeatureButton(label: "create_new_batch".tr(), 
                onTap: _saveBatch, style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: CustomColors.primary,
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

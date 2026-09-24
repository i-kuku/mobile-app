import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class EditBatchPage extends StatefulWidget {
  final Map<String, dynamic> batchData;
  const EditBatchPage({super.key, required this.batchData});

  @override
  State<EditBatchPage> createState() => _EditBatchPageState();
}

class _EditBatchPageState extends State<EditBatchPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _countController;
  late TextEditingController _ageController;
  late TextEditingController _costController;

  late String? _selectedType;
  late String? _selectedUnit;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.batchData['name']);
    _countController = TextEditingController(
      text: widget.batchData['initialCount']?.toString(),
    );
    _ageController = TextEditingController(
      text: widget.batchData['age']?.toString(),
    );
    _costController = TextEditingController(
      text: widget.batchData['purchaseCost']?.toString(),
    );

    _selectedType = widget.batchData['typeOfBird'];
    _selectedUnit = widget.batchData['ageUnit'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    _ageController.dispose();
    _costController.dispose();
    super.dispose();
  }

  bool _isUpdating = false;

  Future<void> _handleUpdate() async {
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    final batchId = widget.batchData['id'];
    if (batchId == null) {
      messenger.showSnackBar(
        SnackBar(content: Text("Missing_batch_id".tr())),
      );
      return;
    }
    setState(() => _isUpdating = true);

    try {
      await Provider.of<BatchProvider>(context, listen: false).updateBatch(
        id: batchId,
        name: _nameController.text.trim(),
        typeOfBird: _selectedType ?? 'layer',
        initialCount: int.tryParse(_countController.text) ?? 0,
        age: int.tryParse(_ageController.text) ?? 0,
        ageUnit: _selectedUnit ?? 'Days',
        purchaseCost: num.tryParse(_costController.text) ?? 0,
      );

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('batch_updated_successfully'.tr())),
        );

        context.pop();
      }
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to update batch: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
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
                "Back".tr(),
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
                  "${"Edit".tr()} ${widget.batchData['name']}",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 48),
                Text(
                  'Batch_Name'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: CustomColors.text,
                    fontSize: 20,
                  ),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.textDisabled),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.textDisabled),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CustomColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter_a_name".tr() : null,
                ),
                SizedBox(height: 48),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'type_of_bird'.tr(),
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: CustomColors.text,
                                  fontSize: 20,
                                ),
                          ),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.textDisabled,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.textDisabled,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            initialValue: _selectedType,
                            items: ['layer', 'broiler'].map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.tr()),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedType = val!),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'number_of_birds'.tr(),
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: CustomColors.text,
                                  fontSize: 20,
                                ),
                          ),
                          TextFormField(
                            controller: _countController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.textDisabled,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.textDisabled,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "enter_a_number".tr();
                              }
                              if (int.tryParse(value) == null) {
                                return 'please_enter_a_valid_number'.tr();
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'enter_the_age'.tr(),
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: CustomColors.text,
                                  fontSize: 20,
                                ),
                          ),
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 8),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.textDisabled,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.textDisabled,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Enter_the_age".tr() : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'age_unit'.tr(),
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: CustomColors.text,
                                  fontSize: 20,
                                ),
                          ),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.textDisabled,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.textDisabled,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            items: ['Days', 'Weeks', 'Months'].map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit.tr()),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedUnit = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 48),
                Text(
                  'cost_of_chicks'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: CustomColors.text,
                    fontSize: 20,
                  ),
                ),
                TextFormField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.textDisabled),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.textDisabled),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CustomColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "enter_the_cost".tr();
                    }
                    if (num.tryParse(value) == null) {
                      return 'please_enter_a_valid_number'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 48),
                FeatureButton(
                  label: _isUpdating ? 'updating...'.tr() : 'update'.tr(),
                  onTap: _handleUpdate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
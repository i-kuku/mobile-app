import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void addItemDialog(BuildContext context, String category,{InventoryItem? itemToEdit}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1.0,
        height: 650,
        child: AddItemForm(
          category: category,
          itemToEdit: itemToEdit,
          ),
      ),
    ),
  );
}

class AddItemForm extends StatefulWidget {
  final String category;
  final InventoryItem? itemToEdit;

  const AddItemForm({
    super.key,
    required this.category,
    this.itemToEdit,
    });

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm>{
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  String? _selectedUnit = "Kg";

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.itemToEdit?.name ?? ""
    );
    _quantityController = TextEditingController(
      text: widget.itemToEdit?.quantity.toString() ?? ""
    );
    _priceController = TextEditingController(
      text: widget.itemToEdit?.price.toString() ?? ""
    );
    
    _selectedUnit = widget.itemToEdit?.unit ?? "Kg";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 30),
          child: Text(
            widget.itemToEdit !=null
            ?"edit_${widget.category}".tr()
            : "add_${widget.category}_to_store".tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: CustomColors.text,
            ),
          ),
        ),
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildLabel("name_of_item".tr()),
                _buildTextField(_nameController),
            
                _buildLabel("quantity".tr()),
                _buildTextField(_quantityController, isNumber: true),
            
                _buildLabel("unit".tr()),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration: _inputDecoration(),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: ['Kg', 'L', 'g', 'Mifuko']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedUnit = val!),
                ),
               SizedBox(height: 16),
                _buildLabel("price_per_unit".tr()),
                _buildTextField(_priceController, isNumber: true),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16,0,16,16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if(_formKey.currentState!.validate()){
                    final item=InventoryItem(
                      id: widget.itemToEdit?.id ?? const Uuid().v4(),
                      name: _nameController.text,
                      quantity: int.tryParse(_quantityController.text) ?? 0,
                      unit: _selectedUnit?? "kg",
                      price: double.tryParse(_priceController.text) ?? 0,
                      category: widget.category,
                    );
                    final provider= context.read<InventoryProvider>();
                    if(widget.itemToEdit!=null){
                      provider.updateInventoryItem(item);
                    }
                    else{
                      provider.addInventoryItem(item);
                    }
                    context.pop(context);
                  }
                  },
                  child: Text(
                    widget.itemToEdit != null ? "update".tr(): "add_item".tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: CustomColors.secondary),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "cancel".tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: CustomColors.text),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: CustomColors.text,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: _inputDecoration(),
        validator:validator ?? (value){
          if(value == null || value.trim().isEmpty){
            return "field_required".tr();
          }
          return null;
        }
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
        focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: CustomColors.primary),
      ),
    );
  }
}

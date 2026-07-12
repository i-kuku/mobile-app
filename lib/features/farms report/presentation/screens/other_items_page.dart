import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class OthersSelector extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItem;
  final void Function(List<Map<String, dynamic>>) onSelectedItemChanged;

  const OthersSelector({
    super.key,
    required this.selectedItem,
    required this.onSelectedItemChanged,
  });

  @override
  State<OthersSelector> createState() => _OthersSelectorState();
}

class _OthersSelectorState extends State<OthersSelector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    if (provider.isloading) {
      return Scaffold(
        appBar: AppBar(elevation: 0),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomColors.primary),
          ),
        ),
      );
    }

    final others = provider.others;

    return OtherItemsPage(
      item: others,
      selectedItem: widget.selectedItem,
      onSelectedItemChanged: widget.onSelectedItemChanged,
    );
  }
}

class OtherItemsPage extends StatefulWidget {
  final List<InventoryItem> item;
  final List<Map<String, dynamic>> selectedItem;
  final void Function(List<Map<String, dynamic>>) onSelectedItemChanged;

  const OtherItemsPage({
    super.key,
    required this.item,
    required this.selectedItem,
    required this.onSelectedItemChanged,
  });

  @override
  State<OtherItemsPage> createState() => _OtherItemsPage();
}

class _OtherItemsPage extends State<OtherItemsPage> {
  late List<Map<String, dynamic>> _selectedItem;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _selectedItem = List<Map<String, dynamic>>.from(widget.selectedItem);
    _initializeControllers();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    for (final item in _selectedItem) {
      final name = item['name'] as String;
      if (!_controllers.containsKey(name)) {
        _controllers[name] = TextEditingController(
          text: item['quantity']?.toString() ?? '',
        );
      }
    }
  }

  void _toggleItem(InventoryItem item, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedItem.any((v) => v['name'] == item.name)) {
          _selectedItem.add({'name': item.name, 'quantity': null});
          _controllers[item.name] = TextEditingController();
        }
      } else {
        _selectedItem.removeWhere((v) => v['name'] == item.name);
        _controllers[item.name]?.dispose();
        _controllers.remove(item.name);
      }
      widget.onSelectedItemChanged(_selectedItem);
    });
  }

  void _updateQuantity(String itemName, String value) {
    setState(() {
      final idx = _selectedItem.indexWhere((v) => v['name'] == itemName);
      if (idx != -1) {
        final quantity = double.tryParse(value);
        if (quantity != null && quantity >= 0) {
          // Find the item to check available stock
          final item = widget.item.firstWhere((v) => v.name == itemName);
          if (quantity <= item.quantity) {
            _selectedItem[idx]['quantity'] = quantity;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'cannot_use_more_than'.tr(
                    namedArgs: {
                      'quantity': item.quantity.toString(),
                      'unit': 'kg'.tr(),
                      'item': item.name,
                    },
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            );
            // Reset the controller to the previous valid value
            _controllers[itemName]?.text =
                _selectedItem[idx]['quantity']?.toString() ?? '';
            return;
          }
        } else {
          _selectedItem[idx]['quantity'] = null;
        }
        widget.onSelectedItemChanged(_selectedItem);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text('farm_reports_entry'.tr()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'select_other_materials_today'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: CustomColors.text),
            ),
            const SizedBox(height: 12),
            if (widget.item.isEmpty) ...[
              Column(
                children: [
                  Text(
                    "cannot_see_any_item_in_the_list".tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: CustomColors.text),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      context.push('/inventory/others');
                    },
                    label: Text("add_item_to_store".tr()),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
            ] else ...[
              ...widget.item.map((item) {
                final isSelected = _selectedItem.any(
                  (v) => v['name'] == item.name,
                );
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(
                    '${item.name.tr()} (${"stock".tr()}: ${item.quantity} ${item.unit.tr()})',
                  ),
                  onChanged: (checked) => _toggleItem(item, checked ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
              const SizedBox(height: 16),
              ..._selectedItem.map((v) {
                final itemName = v['name'] as String;
                // Find the item to get its unit
                final item = widget.item.firstWhere(
                  (item) => item.name == itemName,
                );
                final unit = item.unit;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _controllers[itemName],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            'How much ${itemName.tr()} did you use in ${unit.tr()}?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixText: unit.tr(),
                      ),
                      onChanged: (v) => _updateQuantity(itemName, v),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
            SizedBox(height: 20),
            FeatureButton(label: "continue".tr(), onTap: () {}),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

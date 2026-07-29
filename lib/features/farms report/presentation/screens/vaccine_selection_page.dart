import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class VaccineSelector extends StatelessWidget {
  final List<Map<String, dynamic>> selectedVaccines;
  final void Function(List<Map<String, dynamic>>) onSelectedVaccinesChanged;

  const VaccineSelector({
    super.key,
    required this.selectedVaccines,
    required this.onSelectedVaccinesChanged,
  });

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
    final vaccines = provider.medicines;

    return VaccineSelectionPage(
      vaccines: vaccines,
      selectedVaccines: selectedVaccines,
      onSelectedVaccinesChanged: onSelectedVaccinesChanged,
    );
  }
}

class VaccineSelectionPage extends StatefulWidget {
  final List<InventoryItem> vaccines;
  final List<Map<String, dynamic>> selectedVaccines;
  final void Function(List<Map<String, dynamic>>) onSelectedVaccinesChanged;

  const VaccineSelectionPage({
    super.key,
    required this.vaccines,
    required this.selectedVaccines,
    required this.onSelectedVaccinesChanged,
  });

  @override
  State<VaccineSelectionPage> createState() => _VaccineSelectionPage();
}

class _VaccineSelectionPage extends State<VaccineSelectionPage> {
  late List<Map<String, dynamic>> _selectedVaccines;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
     final providerVaccines = context.read<FarmReportProvider>().vaccinesUsed;
    _selectedVaccines = List<Map<String, dynamic>>.from(
      providerVaccines.isNotEmpty ? providerVaccines : widget.selectedVaccines,
    );
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
    for (final vaccine in _selectedVaccines) {
      final name = vaccine['name'] as String;
      if (!_controllers.containsKey(name)) {
        _controllers[name] = TextEditingController(
          text: vaccine['quantity']?.toString() ?? '',
        );
      }
    }
  }

  void _toggleVaccine(InventoryItem vaccine, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedVaccines.any((v) => v['name'] == vaccine.name)) {
          _selectedVaccines.add({'name': vaccine.name, 'quantity': null});
          _controllers[vaccine.name] = TextEditingController();
        }
      } else {
        _selectedVaccines.removeWhere((v) => v['name'] == vaccine.name);
        _controllers[vaccine.name]?.dispose();
        _controllers.remove(vaccine.name);
      }
      widget.onSelectedVaccinesChanged(_selectedVaccines);
            context.read<FarmReportProvider>().updateVaccines(_selectedVaccines);
    });
  }

  void _updateQuantity(String vaccineName, String value) {
    setState(() {
      final idx = _selectedVaccines.indexWhere((v) => v['name'] == vaccineName);
      if (idx != -1) {
        final quantity = double.tryParse(value);
        if (quantity != null && quantity >= 0) {
          final vaccine = widget.vaccines.firstWhere(
            (v) => v.name == vaccineName,
          );
          if (quantity <= vaccine.quantity) {
            _selectedVaccines[idx]['quantity'] = quantity;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'cannot_use_more_than'.tr(
                    namedArgs: {
                      'quantity': vaccine.quantity.toString(),
                      'unit': vaccine.unit.tr(),
                      'item': vaccine.name,
                    },
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            );
            // Reset the controller to the previous valid value
            _controllers[vaccineName]?.text =
                _selectedVaccines[idx]['quantity']?.toString() ?? '';
            return;
          }
        } else {
          _selectedVaccines[idx]['quantity'] = null;
        }
        widget.onSelectedVaccinesChanged(_selectedVaccines);
        context.read<FarmReportProvider>().updateVaccines(_selectedVaccines);
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
              'select_vaccine_types_today'.tr(),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: CustomColors.text),
            ),
            const SizedBox(height: 8),
            if (widget.vaccines.isEmpty) ...[
              Column(
                children: [
                  Text(
                    "cannot_see_any_vaccine_in_the_list".tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: CustomColors.text),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      context.push('/inventory/medicines');
                    },
                    label: Text("add_vaccine_to_store".tr()),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
            ] else ...[
              ...widget.vaccines.map((vaccine) {
                final isSelected = _selectedVaccines.any(
                  (v) => v['name'] == vaccine.name,
                );
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(
                    '${vaccine.name.tr()} (${"stock".tr()}: ${vaccine.quantity} ${vaccine.unit.tr()})',
                  ),
                  onChanged: (checked) =>
                      _toggleVaccine(vaccine, checked ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
              const SizedBox(height: 16),
              ..._selectedVaccines.map((v) {
                final vaccineName = v['name'] as String;
                // Find the vaccine to get its unit
                final vaccine = widget.vaccines.firstWhere(
                  (vaccine) => vaccine.name == vaccineName,
                );
                final unit = vaccine.unit;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccineName.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _controllers[vaccineName],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            'How much ${vaccineName.tr()} did you use in ${unit.tr()}?',
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
                      onChanged: (v) => _updateQuantity(vaccineName, v),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
            FeatureButton(
              label: "continue".tr(),
              onTap: () {
                context.push('/other_items_selection');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

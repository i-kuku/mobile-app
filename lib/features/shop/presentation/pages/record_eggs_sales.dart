import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/financial%20summaries/provider/financial_provider.dart';
import 'package:ikuku/features/shop/model/sale_model.dart';
import 'package:ikuku/features/shop/presentation/widgets/chicken_type_card.dart';
import 'package:ikuku/features/shop/presentation/widgets/confirmation_dialog.dart';
import 'package:ikuku/features/shop/presentation/widgets/input_fields.dart';
import 'package:ikuku/features/shop/presentation/widgets/record_sale_button.dart';
import 'package:ikuku/features/shop/presentation/widgets/select_card.dart';
import 'package:ikuku/features/shop/provider/sales_provider.dart';
import 'package:provider/provider.dart';

class RecordEggsSalePage extends StatefulWidget {
  const RecordEggsSalePage({super.key});

  @override
  State<RecordEggsSalePage> createState() => _RecordEggsSalePageState();
}

class _RecordEggsSalePageState extends State<RecordEggsSalePage> {
  final Set<String> _selectedTypes = {'eggs'};
  String? _selectedBirdType;

  final _countController = TextEditingController();
  final _priceController = TextEditingController();
  final _chickenCountController = TextEditingController();
  final _chickenPriceController = TextEditingController();

  @override
  void dispose() {
    _countController.dispose();
    _priceController.dispose();
    _chickenCountController.dispose();
    _chickenPriceController.dispose();
    super.dispose();
  }

  void _toggleType(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        if (_selectedTypes.length > 1) _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  void _showConfirmDialog() {
    if (_selectedTypes.contains('chicken')) {
      if (_selectedBirdType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a chicken type')),
        );
        return;
      }
      final chickenCount = int.tryParse(_chickenCountController.text) ?? 0;
      final chickenPrice = double.tryParse(_chickenPriceController.text) ?? 0.0;

      if (chickenCount <= 0 || chickenPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid chicken quantity and price'),
          ),
        );
        return;
      }
    }

    if (_selectedTypes.contains('eggs')) {
      final eggsCount = int.tryParse(_countController.text) ?? 0;
      final eggsPrice = double.tryParse(_priceController.text) ?? 0.0;

      if (eggsCount <= 0 || eggsPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid egg quantity and price'),
          ),
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        onTap: () {
          Navigator.of(dialogContext).pop();
          _handleRecordSale();
        },
      ),
    );
  }

  Future<void> _handleRecordSale() async {
    final salesProvider = context.read<SalesProvider>();

    try {
      if (_selectedTypes.contains('chicken')) {
        final chickenCount = int.tryParse(_chickenCountController.text) ?? 0;
        final chickenPrice =
            double.tryParse(_chickenPriceController.text) ?? 0.0;

        if (chickenCount > 0 && chickenPrice > 0) {
          await salesProvider.addSale(
            SaleModel(
              saleType: 'chicken',
              subType: _selectedBirdType,
              quantity: chickenCount,
              amount: chickenPrice,
            ),
          );
        }
      }

      if (_selectedTypes.contains('eggs')) {
        final eggsCount = int.tryParse(_countController.text) ?? 0;
        final eggsPrice = double.tryParse(_priceController.text) ?? 0.0;

        if (eggsCount > 0 && eggsPrice > 0) {
          await salesProvider.addSale(
            SaleModel(
              saleType: 'eggs',
              subType: null,
              quantity: eggsCount,
              amount: eggsPrice,
            ),
          );
        }
      }

      if (mounted) {
        context.read<FinancialSummaryProvider>().refresh();
        context.pop();
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save sale: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'my_shop'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'record_sale'.tr(),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'what_have_you_sold'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SelectCard(
                    label: 'chicken'.tr(),
                    icon: SvgPicture.asset(
                      'assets/icons/animal-chicken.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                    onTap: () => _toggleType('chicken'),
                    isSelected: _selectedTypes.contains('chicken'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectCard(
                    label: 'eggs'.tr(),
                    icon: SvgPicture.asset(
                      'assets/icons/eggs-f.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                    onTap: () => _toggleType('eggs'),
                    isSelected: _selectedTypes.contains('eggs'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectCard(
                    label: 'manure'.tr(),
                    icon: SvgPicture.asset(
                      'assets/icons/feeds.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                    onTap: () => context.pushReplacement('/record_manure_sale'),
                    isSelected: _selectedTypes.contains('manure'),
                  ),
                ),
              ],
            ),
            if (_selectedTypes.contains('chicken')) ...[
              const SizedBox(height: 28),
              Text(
                'chicken_type'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ChickenTypeCard(
                      label: 'Kienyeji',
                      onTap: () =>
                          setState(() => _selectedBirdType = 'kienyeji'),
                      isSelected: _selectedBirdType == 'kienyeji',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChickenTypeCard(
                      label: 'broiler'.tr(),
                      onTap: () =>
                          setState(() => _selectedBirdType = 'broiler'),
                      isSelected: _selectedBirdType == 'broiler',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChickenTypeCard(
                      label: 'layer'.tr(),
                      onTap: () => setState(() => _selectedBirdType = 'layer'),
                      isSelected: _selectedBirdType == 'layer',
                    ),
                  ),
                ],
              ),
              if (_selectedBirdType != null) ...[
                const SizedBox(height: 28),
                Text(
                  'how_many_chicken'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                InputFields(controller: _chickenCountController, hint: '0'),
                const SizedBox(height: 20),
                Text(
                  'price_of_chicken'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                InputFields(controller: _chickenPriceController, hint: '0'),
              ],
            ],
            if (_selectedTypes.contains('eggs')) ...[
              const SizedBox(height: 28),
              Text(
                'how_many_eggs'.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InputFields(controller: _countController, hint: '0'),
              const SizedBox(height: 20),
              Text(
                'price_of_eggs'.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InputFields(controller: _priceController, hint: '0'),
            ],
            const SizedBox(height: 28),
            RecordSaleButton(onTap: _showConfirmDialog),
          ],
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/shop/model/sale_model.dart';
import 'package:ikuku/features/shop/presentation/widgets/chicken_type_card.dart';
import 'package:ikuku/features/shop/presentation/widgets/input_fields.dart';
import 'package:ikuku/features/shop/presentation/widgets/record_sale_button.dart';
import 'package:ikuku/features/shop/presentation/widgets/select_card.dart';
import 'package:ikuku/features/shop/presentation/widgets/confirmation_dialog.dart';
import 'package:ikuku/features/shop/provider/sales_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class RecordChickenSalePage extends StatefulWidget {
  const RecordChickenSalePage({super.key});

  @override
  State<RecordChickenSalePage> createState() => _RecordChickenSalePageState();
}

class _RecordChickenSalePageState extends State<RecordChickenSalePage> {
  final Set<String> _selectedTypes = {'chicken'};
  String? _selectedBirdType;

  final _countController = TextEditingController();
  final _priceController = TextEditingController();
  final _eggsCountController = TextEditingController();
  final _eggsPriceController = TextEditingController();

  @override
  void dispose() {
    _countController.dispose();
    _priceController.dispose();
    _eggsCountController.dispose();
    _eggsPriceController.dispose();
    super.dispose();
  }

  Future<void> _handleSale() async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    try {
      if (_selectedTypes.contains('chicken')) {
        if (_selectedBirdType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('please_select_chicken_type'.tr())),
          );
          return;
        }
        final count = int.tryParse(_countController.text) ?? 0;
        final price = double.tryParse(_priceController.text) ?? 0.0;

        if (count > 0 && price > 0) {
          await salesProvider.addSale(
            SaleModel(
              saleType: 'chicken',
              subType: _selectedBirdType,
              quantity: count,
              amount: price,
            ),
          );
        }
      }

      if (_selectedTypes.contains('eggs')) {
        final eggsCount = int.tryParse(_eggsCountController.text) ?? 0;
        final eggsPrice = double.tryParse(_eggsPriceController.text) ?? 0.0;

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
      if (mounted) context.pop();
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'what_have_you_sold'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SelectCard(
                    label: 'chicken'.tr(),
                    onTap: () {
                      _toggleType('chicken');
                    },
                    isSelected: true,
                    icon: SvgPicture.asset(
                      'assets/icons/animal-chicken.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: SelectCard(
                    label: 'eggs'.tr(),
                    onTap: () => _toggleType('eggs'),

                    isSelected: false,
                    icon: SvgPicture.asset(
                      'assets/icons/eggs-f.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: SelectCard(
                    label: 'manure'.tr(),
                    onTap: () => context.pushReplacement('/record_manure_sale'),
                    isSelected: false,
                    icon: SvgPicture.asset(
                      'assets/icons/feeds.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedTypes.contains('chicken')) ...[
              const SizedBox(height: 28),
              Text(
                'chicken_type'.tr(),
                style: TextStyle(fontSize: 18, color: CustomColors.text),
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
                  SizedBox(width: 8),
                  Expanded(
                    child: ChickenTypeCard(
                      label: 'broiler'.tr(),
                      onTap: () =>
                          setState(() => _selectedBirdType = 'broiler'),
                      isSelected: _selectedBirdType == 'broiler',
                    ),
                  ),
                  SizedBox(width: 8),
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
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InputFields(controller: _countController, hint: '0'),
                const SizedBox(height: 20),
                Text(
                  'price_of_chicken'.tr(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InputFields(controller: _priceController, hint: '0'),
              ],
            ],
            if (_selectedTypes.contains('eggs')) ...[
              const SizedBox(height: 28),
              Text(
                'how_many_eggs'.tr(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InputFields(controller: _eggsCountController, hint: '0'),
              const SizedBox(height: 20),
              Text(
                'price_of_eggs'.tr(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InputFields(controller: _eggsPriceController, hint: '0'),
            ],
            const SizedBox(height: 28),
            RecordSaleButton(onTap: _showConfirmDialog),
          ],
        ),
      ),
    );
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
      final count = int.tryParse(_countController.text) ?? 0;
      final price = double.tryParse(_priceController.text) ?? 0.0;
      if (count <= 0 || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid chicken count and price'),
          ),
        );
        return;
      }
    }
    if (_selectedTypes.contains('eggs')) {
      final eggsCount = int.tryParse(_eggsCountController.text) ?? 0;
      final eggsPrice = double.tryParse(_eggsPriceController.text) ?? 0.0;
      if (eggsCount <= 0 || eggsPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid egg count and price'),
          ),
        );
        return;
      }
    }
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        onTap: () {
           
          context.push('/my_shop');
         _handleSale();
        },
      ),
    );
  }
}

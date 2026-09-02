import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/shop/model/sale_model.dart';
import 'package:ikuku/features/shop/presentation/widgets/input_fields.dart';
import 'package:ikuku/features/shop/presentation/widgets/record_sale_button.dart';
import 'package:ikuku/features/shop/presentation/widgets/select_card.dart';
import 'package:ikuku/features/shop/presentation/widgets/confirmation_dialog.dart';
import 'package:ikuku/features/shop/provider/sales_provider.dart';
import 'package:provider/provider.dart';

class RecordManureSalePage extends StatefulWidget {
  const RecordManureSalePage({super.key});

  @override
  State<RecordManureSalePage> createState() => _RecordManureSalePageState();
}

class _RecordManureSalePageState extends State<RecordManureSalePage> {
  final _bagsController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _bagsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleManureSave() async {
    final bags = int.tryParse(_bagsController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    try {
      final salesProvider = Provider.of<SalesProvider>(context, listen: false);

      await salesProvider.addSale(
        SaleModel(
          saleType: 'manure',
          subType: null,
          quantity: bags,
          amount: price,
        ),
      );
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
              'record_sales'.tr(),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'what_have_you_sold'.tr(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SelectCard(
                    label: 'Chicken',
                    onTap: () {
                      context.push('/record_chicken_sale');
                    },
                    isSelected: false,
                    icon: SvgPicture.asset('assets/icons/animal-chicken.svg',
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
                    label: 'Eggs',
                    onTap: () {
                      context.push('/record_eggs_sale');
                    },
                    isSelected: false,
                    icon: SvgPicture.asset('assets/icons/eggs-f.svg',
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
                    label: 'Manure',
                    onTap: () {
                      context.push('/record_manure_sale');
                    },
                    isSelected: true,
                    icon: SvgPicture.asset('assets/icons/feeds.svg',
                    colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 28),
            Text(
              'how_many_bags_of_manure'.tr(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InputFields(controller: _bagsController, hint: '0'),
            const SizedBox(height: 20),
            Text(
              'price_of_manure_bags'.tr(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InputFields(controller: _priceController, hint: '0'),
            const SizedBox(height: 28),
            RecordSaleButton(
              onTap: _showConfirmDialog,
            ),
            
          ],
        ),
      ),
    );
  }
  void _showConfirmDialog() {
  final bags = int.tryParse(_bagsController.text) ?? 0;
  final price = double.tryParse(_priceController.text) ?? 0.0;

  if (bags <= 0 || price <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter valid quantities and price')),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (dialogContext) => ConfirmationDialog(
      onTap: () {
        Navigator.of(dialogContext).pop(); 
        _handleManureSave(); 
      },
    ),
  );
}
}

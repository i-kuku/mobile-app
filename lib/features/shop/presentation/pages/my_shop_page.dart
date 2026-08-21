import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/shop/presentation/widgets/selection_card.dart';
import 'package:ikuku/features/shop/presentation/widgets/total_sales_card.dart';
import 'package:ikuku/theme/app_theme.dart';

class MyShopPage extends StatefulWidget {
  const MyShopPage({super.key});

  @override
  State<MyShopPage> createState() => _MyShopPageState();
}

class _MyShopPageState extends State<MyShopPage> {
  SaleType _selectedType = SaleType.chicken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/'),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            const Text(
              'My Shop',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TotalSalesCard(
            amount: 'Ksh 3000',
            onRecordSale: () => context.push('/record_sale'),
          ),
          const SizedBox(height: 16),
          SaleTypeSelectionCard(
            selectedType: _selectedType,
            onChanged: (type) => setState(() => _selectedType = type),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LATEST SALES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'All sales',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Static placeholder rows — matching the screenshot, no real data yet
          _saleRow(
            icon: Icons.pets,
            label: '1 Kienyeji Chicken',
            date: '19 August 2026',
            amount: 'Ksh 1200',
          ),
          _saleRow(
            icon: Icons.pets,
            label: '1 Broiler Chicken',
            date: '19 August 2026',
            amount: 'Ksh 600',
          ),
          _saleRow(
            icon: Icons.egg,
            label: '5 Eggs',
            date: '19 August 2026',
            amount: 'Ksh 75',
          ),
          _saleRow(
            icon: Icons.pets,
            label: '1 Layer Chicken',
            date: '19 August 2026',
            amount: 'Ksh 500',
          ),
          _saleRow(
            icon: Icons.shopping_bag_outlined,
            label: '1 Bag Manure',
            date: '19 August 2026',
            amount: 'Ksh 200',
          ),
        ],
      ),
    );
  }

  Widget _saleRow({
    required IconData icon,
    required String label,
    required String date,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.green.shade50,
            child: Icon(icon, size: 18, color: CustomColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: CustomColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

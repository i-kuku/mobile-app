import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/shop/presentation/widgets/sale_card.dart';
import 'package:ikuku/features/shop/presentation/widgets/total_sales_card.dart';
import 'package:ikuku/features/shop/provider/sales_provider.dart';
import 'package:provider/provider.dart';

class MyShopPage extends StatefulWidget {
  const MyShopPage({super.key});

  @override
  State<MyShopPage> createState() => _MyShopPageState();
}

class _MyShopPageState extends State<MyShopPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<SalesProvider>().fetchSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = context.watch<SalesProvider>();
    final displaySales = salesProvider.dashboardSales;
    final todayTotal = salesProvider.todaytotalSales;

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
            Text(
              'my_shop'.tr(),
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
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: () => salesProvider.fetchSales(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TotalSalesCard(
                amount: 'Ksh ${todayTotal.toStringAsFixed(0)}',
                onRecordSale: () {
                  context.push('/record_sale');
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'latest_sales'.tr(),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/all_sales'),
                    child: Text(
                      'all_sales'.tr(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              if (salesProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (displaySales.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No sales recorded yet')),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: displaySales.length,
                  itemBuilder: (context, index) {
                    final sale = displaySales[index];
                    return SaleCard(sale: sale);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

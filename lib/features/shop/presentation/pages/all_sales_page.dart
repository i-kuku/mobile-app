import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/shop/model/sale_model.dart';
import 'package:ikuku/features/shop/provider/sales_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class AllSalesPage extends StatefulWidget {
  const AllSalesPage({super.key});

  @override
  State<AllSalesPage> createState() => _AllSalesPageState();
}

class _AllSalesPageState extends State<AllSalesPage> {
  DateTime? _filterDate;

  String _getIconPath(String saleType) {
    switch (saleType.toLowerCase()) {
      case 'chicken':
        return 'assets/icons/animal-chicken.svg';
      case 'eggs':
        return 'assets/icons/eggs-f.svg';
      case 'manure':
        return 'assets/icons/feeds.svg';
      default:
        return 'assets/icons/animal-chicken.svg';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _filterDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = context.watch<SalesProvider>();
    Map<String, List<SaleModel>> groupedSales =
        salesProvider.salesGroupedByDate;

    // Apply Filter if selected via DatePicker
    if (_filterDate != null) {
      final filteredMap = <String, List<SaleModel>>{};
      groupedSales.forEach((key, list) {
        final matches = list
            .where(
              (s) =>
                  s.createdAt.year == _filterDate!.year &&
                  s.createdAt.month == _filterDate!.month &&
                  s.createdAt.day == _filterDate!.day,
            )
            .toList();
        if (matches.isNotEmpty) filteredMap[key] = matches;
      });
      groupedSales = filteredMap;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'my_shop'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: CustomColors.text,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back, color: CustomColors.text),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'all'.tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(color: CustomColors.text),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickDate,

                    label: Text(
                      _filterDate == null
                          ? 'select_date'.tr()
                          : '${_filterDate!.day}/${_filterDate!.month}/${_filterDate!.year}',
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (groupedSales.isEmpty)
                Center(child: Text('no_sales_found'.tr()))
              else
                ...groupedSales.entries.map((entry) {
                  final groupTitle = entry.key;
                  final salesList = entry.value;
                  final groupTotal = salesList.fold(
                    0.0,
                    (sum, item) => sum + item.amount,
                  );

                  return Container(
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            groupTitle,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ...salesList.map(
                          (sale) => Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade300,
                                  radius: 14,
                                  child: SvgPicture.asset(
                                    _getIconPath(sale.saleType),
                                    width: 16,
                                    height: 16,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.grey,
                                      BlendMode
                                          .srcIn, 
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    sale.displayTitle,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Text(
                                  'Ksh ${sale.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: CustomColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.lightGreen.shade50,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'total'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.text,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Ksh ${groupTotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

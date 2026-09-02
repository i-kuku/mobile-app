import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ikuku/features/shop/model/sale_model.dart';
import 'package:ikuku/theme/app_theme.dart';

class SaleCard extends StatefulWidget {
  final SaleModel sale;

  const SaleCard({super.key, required this.sale});

  @override
  State<SaleCard> createState() => _SaleCardState();
}

class _SaleCardState extends State<SaleCard> {
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

  Color _getAvatarColor(String saleType) {
  switch (saleType.toLowerCase()) {
    case 'chicken':
      return Colors.lightGreen.shade100; 
    case 'eggs':
      return const Color(0xFFFFF3E0); 
    case 'manure':
      return Colors.lightGreen.shade100; 
    default:
      return const Color(0xFFF5F5F5); 
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getAvatarColor(widget.sale.saleType),
                  child: SvgPicture.asset(
                    _getIconPath(widget.sale.saleType),
                    width:  20,
                    height: 20,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sale.displayTitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(color: CustomColors.text),
                    ),
                    Text(
                      DateFormat('d MMMM yyyy').format(widget.sale.createdAt),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(width: 15,),
               
              ],
            ),
             Text(
                  'Ksh ${widget.sale.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

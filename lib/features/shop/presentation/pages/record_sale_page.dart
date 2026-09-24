import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/shop/presentation/widgets/select_card.dart';

class RecordSalePage extends StatefulWidget {
  const RecordSalePage({super.key});

  @override
  State<RecordSalePage> createState() => _RecordSalePageState();
}

class _RecordSalePageState extends State<RecordSalePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'my_shop'.tr(),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'what_have_you_sold'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SelectCard(
                    label: 'Chicken',
                    onTap: () {
                      context.push('/record_chicken_sale');
                    },
                    isSelected: false,
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
                    label: 'Eggs',
                    onTap: () {
                      context.push('/record_eggs_sale');
                    },
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
                    label: 'Manure',
                    onTap: () {
                      context.push('/record_manure_sale');
                    },
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
          ],
        ),
      ),
    );
  }
}

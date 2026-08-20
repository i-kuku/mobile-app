import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/shop/presentation/widgets/selection_card.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:flutter_svg/svg.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('my_shop'.tr(),style: Theme.of(context).textTheme.titleLarge!.copyWith(color: CustomColors.primary),),
        leading: Icon(Icons.arrow_back),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20,),
          Text(
            'what_have_you_sold'.tr(),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.black,fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              SelectionCard(
                icon: SvgPicture.asset('assets/icons/animal-chicken.svg'),
                label: 'Chicken', 
                onTap: (){}),
                SizedBox(width: 10,),
                 SelectionCard(
                  icon:  SvgPicture.asset('assets/icons/eggs-f.svg'),
                label: 'Eggs', 
                onTap: (){}),
                SizedBox(width: 10,),
                 SelectionCard(
                 icon:  SvgPicture.asset('assets/icons/feeds.svg'),
                label: 'Manure', 
                onTap: (){})
            ],
          )
        ],
      ),
    );
  }
}
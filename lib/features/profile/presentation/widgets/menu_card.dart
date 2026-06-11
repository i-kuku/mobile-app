import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';


class MenuCard extends StatelessWidget {
  final  IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon,color:iconColor,size: 20,),
        title:Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color:CustomColors.text,fontSize:16, ),
        ),
        trailing: Icon(Icons.arrow_forward_ios,color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
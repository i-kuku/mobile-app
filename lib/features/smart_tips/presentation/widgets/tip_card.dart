import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/smart_tips/model/smart_tips_model.dart';
import 'package:ikuku/theme/app_theme.dart';

class TipCard extends StatelessWidget {
  final SmartTips tip;
  final VoidCallback onReadMorePressed;

  const TipCard({
    super.key,
    required this.tip,
    required this.onReadMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 2),
       padding: EdgeInsets.all(10),
      height: 200,
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:Colors.grey[400],
        
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tip.emoji,
                style: TextStyle(fontSize: 24),
                ),
              Expanded(
                child: Text(
                  tip.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: CustomColors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tip.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(color: CustomColors.text),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: onReadMorePressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'read_more'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: CustomColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 8,
                    color: CustomColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

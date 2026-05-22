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
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.emoji, style: TextStyle(fontSize: 24)),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    tip.title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: CustomColors.text,
                      fontWeight: FontWeight.bold,
                    ),
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
            SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: onReadMorePressed,
                icon: Icon(Icons.arrow_forward, size: 16),
                label: Text('read_more'.tr()),
                style: TextButton.styleFrom(
                  foregroundColor: CustomColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/theme/app_theme.dart';

class PopUp extends StatelessWidget {
  final String title;
  final Widget icon;
  final String message;
  final String mainButtonText;
  final String secondaryButtonText;
  final VoidCallback? onMainAction;
  final VoidCallback? onsecondaryAction;

  const PopUp({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
    required this.mainButtonText,
    required this.secondaryButtonText,
    this.onMainAction,
    this.onsecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: CustomColors.text,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 100,
              width: 100,
              child: icon,
              ),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: CustomColors.text,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: onMainAction ?? () => context.pop(),        
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: CustomColors.secondary),
                    fixedSize: const Size(100, 50),
                    padding: EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    mainButtonText,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: CustomColors.text,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onsecondaryAction ?? () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.primary,
                    fixedSize: const Size(100, 50),
                    padding: EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    secondaryButtonText,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color:Colors.white,fontSize: 16),
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

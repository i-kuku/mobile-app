import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/theme/app_theme.dart';

class PopUp extends StatelessWidget {
  final Widget icon;
  final String messagebefore;
  final String batchName;
  final String messageAfter;
  final String? mainButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onMainAction;
  final VoidCallback? onsecondaryAction;

  const PopUp({
    super.key,
    required this.icon,
    this.messagebefore = "",
    this.batchName = "",
    this.messageAfter = "",
    this.mainButtonText,
    this.secondaryButtonText,
    this.onMainAction,
    this.onsecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: 333,
          height: 273,
          child: Column(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100, child: Center(child: icon)),
                  SizedBox(height: 24),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(text: "${messagebefore.tr()} "),
                        TextSpan(
                          text: batchName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: " ${messageAfter.tr()}"),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              if (mainButtonText != null || secondaryButtonText != null)
                _buildButtons(context)
              else
                SizedBox(height: 48),

              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (mainButtonText != null && secondaryButtonText != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onsecondaryAction ?? () => context.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: CustomColors.primary),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                secondaryButtonText!.tr(),
                style: TextStyle(
                  color: CustomColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: onMainAction,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                mainButtonText!.tr(),
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onMainAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(mainButtonText!, style: TextStyle(color: Colors.red)),
      ),
    );
  }
}

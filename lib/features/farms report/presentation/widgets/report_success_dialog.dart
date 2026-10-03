import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ikuku/theme/app_theme.dart';

class ReportSuccessDialog extends StatelessWidget {
  final VoidCallback onBackToDashboard;

  const ReportSuccessDialog({super.key, required this.onBackToDashboard});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(
          color: Color(0xFF0D652D),
          width: 2,
        ), // Outer green border
      ),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              'daily_report_saved'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: CustomColors.primary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),

            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF2EB), // Light green circle background
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  30,
                ), 
                child: SvgPicture.asset(
                  'assets/icons/success_checkmark.svg',
                  height: 100,
                ),
              ),
            ),
             SizedBox(height: 32),
            Text(
              'great_job_keeping_your_records_up_to_date'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Back to Dashboard button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onBackToDashboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF006422,
                  ), // Solid green button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child:Text(
                  'back_to_dashboard'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

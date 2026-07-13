import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/custom_notes_field.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';

class AdditionalNotesPage extends StatefulWidget {
  const AdditionalNotesPage({super.key});

  @override
  State<AdditionalNotesPage> createState() => _AdditionalNotesPageState();
}

class _AdditionalNotesPageState extends State<AdditionalNotesPage> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CustomColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "farm_report_entry".tr(),
          style: TextStyle(
            color: CustomColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "additional_notes".tr(),
                      style: TextStyle(color: CustomColors.text, fontSize: 18),
                    ),
                    const SizedBox(height: 24),

                    // Super clean call!
                    CustomNotesField(controller: _notesController),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: FeatureButton(label: "continue".tr(), onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

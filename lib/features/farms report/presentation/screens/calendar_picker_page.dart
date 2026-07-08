import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';

void main() => runApp(const MaterialApp(home: CalendarPickerPage()));

class CalendarPickerPage extends StatefulWidget {
  const CalendarPickerPage({super.key});

  @override
  State<CalendarPickerPage> createState() => _CalendarPickerPage();
}

class _CalendarPickerPage extends State<CalendarPickerPage> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CustomColors.primary, // Header and selected circle green
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: CustomColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:  Icon(Icons.arrow_back, color: CustomColors.primary),
        title:  Text(
          "farm_report_entry".tr(),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 24,
            color: CustomColors.primary,
          )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "select_report_date".tr(),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 24,
            color: CustomColors.text,
          ),
            ),
            const SizedBox(height: 8),
             Text(
              "choose_date".tr(),
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
             Text(
              "report_date".tr(),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 24,
            color: CustomColors.text,
          ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              readOnly: true, 
              onTap: () => _selectDate(
                context,
              ),
              mouseCursor: SystemMouseCursors
                  .click, 
              style: TextStyle(fontSize: 18, letterSpacing: 1.1),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color:Colors.grey,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: CustomColors.primary,
                    width: 1.5,
                  ),
                ),

                suffixIcon: const Icon(
                  Icons.calendar_today,
                  color: CustomColors.primary,
                ),
              ),
            ),

            const Spacer(),
            FeatureButton(
              label: "continue".tr(), 
              onTap: (){}),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
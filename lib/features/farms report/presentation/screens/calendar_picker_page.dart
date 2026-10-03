import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';


class CalendarPickerPage extends StatefulWidget {
  final ChickenBatch? batch;
  final List<DateTime> reportedDates;
  const CalendarPickerPage({super.key, this.batch, this.reportedDates = const []});

  @override
  State<CalendarPickerPage> createState() => _CalendarPickerPage();
}

class _CalendarPickerPage extends State<CalendarPickerPage> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // if(widget.batch!= null){
    //   fetchBatchRecords(widget.batch!.id);
    // }
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: today,
      selectableDayPredicate: (DateTime date) {
        // Disable future dates
        if (date.isAfter(today)) {
          return false;
        }

        // Disable dates that already have reports for this batch
        return !widget.reportedDates.any(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        );
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CustomColors.primary, // Header and selected circle green
              onPrimary: Colors.white,
              onSurface: CustomColors.text,
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
        leading: IconButton(
          color: CustomColors.primary,
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "farm_report_entry".tr(),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 24,
            color: CustomColors.primary,
          ),
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
              onTap: () => _selectDate(context),
              mouseCursor: SystemMouseCursors.click,
              style: TextStyle(fontSize: 18, letterSpacing: 1.1),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
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
  onTap: () {
    context.read<FarmReportProvider>().setReportDate(_selectedDate);
    context.push('/chicken_reduction');
  },
),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

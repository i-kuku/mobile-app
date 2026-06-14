import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

class RecoveryPhonePage extends StatefulWidget {
  const RecoveryPhonePage({super.key});

  @override
  State<RecoveryPhonePage> createState() => _RecoveryPhonePageState();
}

class _RecoveryPhonePageState extends State<RecoveryPhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "profile".tr(),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: CustomColors.primary,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          SizedBox(height: 16),
          Text(
            "add_recovery_number".tr(),
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(fontSize: 20),
          ),
          SizedBox(height: 16),
          Text(
            "phone_number".tr(),
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontSize: 20,
              color: CustomColors.primary,
            ),
          ),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "0712 000 000",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: CustomColors.primary),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: CustomColors.secondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: Text(
                  "cancel".tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(color: CustomColors.text),
                ),
              ),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "save".tr(),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

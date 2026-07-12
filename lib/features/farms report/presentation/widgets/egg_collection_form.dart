import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

class EggCollectionForm extends StatefulWidget {
  const EggCollectionForm({super.key});

  @override
  State<EggCollectionForm> createState() => _EggCollectionFormState();
}

class _EggCollectionFormState extends State<EggCollectionForm> {
  bool? _collectedEggs;
  bool? _gradeEggs;

  final TextEditingController _totalEggsController = TextEditingController();
  final TextEditingController _bigEggsController = TextEditingController();
  final TextEditingController _deformedEggsController = TextEditingController();
  final TextEditingController _brokenEggsController = TextEditingController();

  @override
  void dispose() {
    _totalEggsController.dispose();
    _bigEggsController.dispose();
    _deformedEggsController.dispose();
    _brokenEggsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "have_you_collected_eggs_today".tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: CustomColors.text,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRadioButton(
              title: "yes".tr(),
              value: true,
              groupValue: _collectedEggs,
              onChanged: (val) => setState(() => _collectedEggs = val),
            ),
            const SizedBox(width: 24),
            _buildRadioButton(
              title: "no".tr(),
              value: false,
              groupValue: _collectedEggs,
              onChanged: (val) => setState(() {
                _collectedEggs = val;
                _gradeEggs = null;
              }),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_collectedEggs == true) ...[
          _buildInputField(
            hintText: "how_many_eggs_have_you_collected_today?".tr(),
            controller: _totalEggsController,
          ),
          const SizedBox(height: 24),
          Text(
            "would_you_like_to_grade_your_eggs?".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: CustomColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildRadioButton(
                title: "yes".tr(),
                value: true,
                groupValue: _gradeEggs,
                onChanged: (val) => setState(() => _gradeEggs = val),
              ),
              const SizedBox(width: 24),
              _buildRadioButton(
                title: "no".tr(),
                value: false,
                groupValue: _gradeEggs,
                onChanged: (val) => setState(() => _gradeEggs = val),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_gradeEggs == true) ...[
            _buildInputField(
              hintText: "number_of_big_eggs".tr(),
              controller: _bigEggsController,
            ),
            _buildInputField(
              hintText: "number_of_deformed_eggs",
              controller: _deformedEggsController,
            ),
            _buildInputField(
              hintText: "number_of_broken_eggs".tr(),
              controller: _brokenEggsController,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildRadioButton({
    required String title,
    required bool value,
    required bool? groupValue,
    required ValueChanged<bool> onChanged,
  }) {
    final bool isSelected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? CustomColors.primary : CustomColors.text,
                  width: isSelected ? 6.5 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: CustomColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: CustomColors.text, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: CustomColors.primary,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

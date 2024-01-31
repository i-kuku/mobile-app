import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/theme/colors.dart';

class CustomTextFieldDropdown extends StatefulWidget {
  final String? label;
  final String? hint;
  final List<String> items;

  const CustomTextFieldDropdown(
      {super.key, this.label, this.hint, required this.items});

  @override
  State<CustomTextFieldDropdown> createState() =>
      _CustomTextFieldDropdownState();
}

class _CustomTextFieldDropdownState extends State<CustomTextFieldDropdown> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton2(
      items: widget.items
          .map((item) => DropdownMenuItem(
              value: item,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: item == selectedValue
                        ? primaryAlt
                        : Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )))
          .toList(),
      hint: widget.hint == null
          ? null
          : Text(
              widget.hint!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
      style: Theme.of(context).textTheme.bodyLarge,
      value: selectedValue,
      onChanged: (String? value) {
        setState(() {
          selectedValue = value;
        });
      },
      buttonStyleData: const ButtonStyleData(width: double.infinity),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: MaterialStateProperty.all(6),
          thumbVisibility: MaterialStateProperty.all(true),
        ),
      ),
    );
  }
}

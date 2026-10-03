import 'package:flutter/material.dart';
import 'package:ikuku/theme/app_theme.dart';

class CustomNotesField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText; // Changed from hintText to labelText
  final int maxLines;

  const CustomNotesField({
    super.key,
    required this.controller,
    this.labelText = "Notes", // Default label text
    this.maxLines = 3, // Reduced default maxLines from 5 to 3
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 18, color: CustomColors.text),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: CustomColors.text, // Dark green text matching your headers
          fontSize: 18,
        ),
        floatingLabelBehavior:
            FloatingLabelBehavior.always, // Forces label into the border gap
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: CustomColors.primary, // Green border visible immediately
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: CustomColors.primary, width: 2.5),
        ),
      ),
    );
  }
}

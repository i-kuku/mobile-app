import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final Widget? suffixIcon;

  const CustomTextField({super.key, required this.label, this.suffixIcon});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      autofocus: false,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: Theme.of(context).textTheme.bodyLarge,
        suffixIcon: widget.suffixIcon
      ),

    );
  }
}

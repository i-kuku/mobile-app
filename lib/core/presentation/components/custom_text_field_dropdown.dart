import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final List<String> items;

  const CustomTextField({super.key, required this.label, required this.items});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      autofocus: false,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: Theme.of(context).textTheme.bodyLarge,
      ),
      items: widget.items
          .map((item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodyMedium,
              )))
          .toList(),
      onChanged: (String? value) {},
    );
  }
}

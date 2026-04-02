import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:ikuku/shared/utils/validators.dart';

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final bool isPassword;
  final bool isEmail;
  final String hintText;
  final String? labelText;
  final bool isLoading;
  final int? minimumCharacters;
  final bool isUsername;
  final TextInputType keyboardType;
  final bool isRequired;
  final int? maxLines;
  final int? minLines;
  final void Function(String text)? onChanged;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    this.isPassword = false,
    this.isEmail = false,
    this.isUsername = false,
    required this.hintText,
    this.labelText,
    required this.isLoading,
    this.minimumCharacters,
    this.keyboardType = TextInputType.text,
    this.isRequired = true,
    this.maxLines,
    this.minLines,
    this.onChanged,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool obscureText = true;

  void toggleVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  String? _validator(String? value) {
    String fieldName = widget.labelText ?? widget.hintText;

    if (widget.isRequired) {
      final requiredCheck = requiredField(value, fieldName: fieldName);
      if (requiredCheck != null) return requiredCheck;
    }

    if (widget.minimumCharacters != null) {
      final minCheck = minLength(
        value,
        widget.minimumCharacters!,
        fieldName: fieldName,
      );
      if (minCheck != null) return minCheck;
    }

    if (widget.isEmail) {
      final emailCheck = emailValidator(value, fieldName: fieldName);
      if (emailCheck != null) return emailCheck;
    }

    if (widget.isPassword) {
      final passCheck = passwordValidator(value, fieldName: fieldName);
      if (passCheck != null) return passCheck;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: (String text) {
        if (widget.onChanged != null) {
          widget.onChanged!(text);
        }
      },
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      focusNode: widget.focusNode,
      keyboardType: widget.isEmail
          ? TextInputType.emailAddress
          : widget.maxLines != null
          ? TextInputType.multiline
          : widget.keyboardType,
      maxLines: widget.maxLines ?? 1,
      minLines: widget.minLines,
      readOnly: widget.isLoading,
      obscureText: widget.isPassword ? obscureText : false,
      textInputAction: widget.nextFocusNode != null
          ? TextInputAction.next
          : TextInputAction.done,
      style: Theme.of(context).textTheme.bodyMedium,
      validator: _validator,
      onFieldSubmitted: (_) {
        if (widget.nextFocusNode != null) {
          FocusScope.of(context).requestFocus(widget.nextFocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
        labelText: widget.labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always, 
        labelStyle: TextStyle(fontWeight: FontWeight.w500),
        hintText: widget.hintText,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: Theme.of(context).hintColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        prefixIcon: widget.isPassword
            ? Icon(
                Icons.lock_outline,
                size: 20,
                color: Theme.of(context).cardColor,
              )
            : widget.isEmail
            ? Icon(
                Icons.email_outlined,
                size: 20,
                color: Theme.of(context).cardColor,
              )
            : widget.isUsername
            ? Icon(
                Icons.person_outline_outlined,
                size: 20,
                color: Theme.of(context).cardColor,
              )
            : null,
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: toggleVisibility,
                child: Icon(
                  obscureText ? Iconsax.eye_outline : Iconsax.eye_slash_outline,
                  color: Theme.of(context).cardColor,
                ),
              )
            : null,
        enabledBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green.shade700, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(
            width: 0.5,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(
            width: 0.5,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
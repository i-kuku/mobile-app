import 'package:flutter/material.dart';
import 'package:ikuku/shared/utils/validators.dart';
import 'package:ikuku/theme/app_theme.dart';

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
  // Kept in State so the visibility toggle survives parent rebuilds
  // (e.g. the auth form rebuilding while a request is loading).
  bool _obscureText = true;

  void toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
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
      onChanged: (val) {
        if (widget.onChanged != null) widget.onChanged!(val);
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
      onTap: widget.isLoading ? null : () => widget.focusNode.requestFocus(),
      obscureText: widget.isPassword ? _obscureText : false,
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
            ? Icon(Icons.lock_outline, size: 20, color: CustomColors.primary)
            : widget.isEmail
            ? Icon(Icons.email_outlined, size: 20, color: CustomColors.primary)
            : widget.isUsername
            ? Icon(
                Icons.person_outline_outlined,
                size: 20,
                color: CustomColors.primary,
              )
            : null,
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: toggleVisibility,
                child: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: CustomColors.primary,
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
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

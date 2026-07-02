import 'package:flutter/material.dart';
import 'package:ikuku/shared/utils/validators.dart';
import 'package:ikuku/theme/app_theme.dart';

class TextFieldWidget extends StatelessWidget {
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

  TextFieldWidget({
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

  final ValueNotifier<bool> obscureText = ValueNotifier(true);

  void toggleVisibility() {
    obscureText.value = !obscureText.value;
  }

  String? _validator(String? value) {
    String fieldName = labelText ?? hintText;

    if (isRequired) {
      final requiredCheck = requiredField(value, fieldName: fieldName);
      if (requiredCheck != null) return requiredCheck;
    }

    if (minimumCharacters != null) {
      final minCheck = minLength(
        value,
        minimumCharacters!,
        fieldName: fieldName,
      );
      if (minCheck != null) return minCheck;
    }

    if (isEmail) {
      final emailCheck = emailValidator(value, fieldName: fieldName);
      if (emailCheck != null) return emailCheck;
    }

    if (isPassword) {
      final passCheck = passwordValidator(value, fieldName: fieldName);
      if (passCheck != null) return passCheck;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: obscureText,
      builder: (context, value, child) {
        return TextFormField(
          controller: controller,
          onChanged: (val) {
            if (onChanged != null) onChanged!(val);
          },

          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          focusNode: focusNode,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : maxLines != null
              ? TextInputType.multiline
              : keyboardType,
          maxLines: maxLines ?? 1,
          minLines: minLines,
          onTap: isLoading ? null : () => focusNode.requestFocus(),
          obscureText: isPassword ? obscureText.value : false,
          textInputAction: nextFocusNode != null
              ? TextInputAction.next
              : TextInputAction.done,
          style: Theme.of(context).textTheme.bodyMedium,
          validator: _validator,
          onFieldSubmitted: (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            hintText: hintText,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Theme.of(context).hintColor),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            prefixIcon: isPassword
                ? Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: CustomColors.primary,
                  )
                : isEmail
                ? Icon(
                    Icons.email_outlined,
                    size: 20,
                    color: CustomColors.primary,
                  )
                : isUsername
                ? Icon(
                    Icons.person_outline_outlined,
                    size: 20,
                    color: CustomColors.primary,
                  )
                : null,
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: toggleVisibility,
                    child: Icon(
                      obscureText.value
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
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.7),
              ),
            ),
          ),
        );
      },
    );
  }
}

bool validatePhoneNumber(String? phoneNumber) {
  if (phoneNumber == null ||
      phoneNumber.trim().isEmpty ||
      phoneNumber.length != 10) {
    return false;
  } else {
    return true;
  }
}

String? requiredField(String? value, {String? fieldName}) {
  if (value == null || value.isEmpty) {
    return '${fieldName ?? "This field"} is required';
  }
  return null;
}

String? minLength(String? value, int min, {String? fieldName}) {
  if (value != null && value.length < min) {
    return '${fieldName ?? "This field"} must be at least $min characters';
  }
  return null;
}

String? emailValidator(String? value, {String? fieldName}) {
  if (value == null || value.isEmpty) {
    return '${fieldName ?? "Email"} is required';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
  return null;
}

String? passwordValidator(
  String? value, {
  String? fieldName,
  int minLength = 6,
}) {
  if (value == null || value.isEmpty) {
    return '${fieldName ?? "Password"} is required';
  }
  if (value.length < minLength) {
    return '${fieldName ?? "Password"} must be at least $minLength characters';
  }
  return null;
}

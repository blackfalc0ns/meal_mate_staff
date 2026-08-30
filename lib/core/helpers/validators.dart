import '../helpers/regex.dart';

abstract class Validations {
  static String? validateName(Object? context, String? name) {
    final value = name?.trim() ?? '';
    if (value.isEmpty) {
      return 'Name is required';
    }
    if (!AppRegExp.isNameValid(value)) {
      return 'Name is not valid';
    }
    return null;
  }

  static String? validateEmail(Object? context, String? email) {
    final value = email?.trim() ?? '';
    if (value.isEmpty) {
      return 'Email is required';
    }
    if (!AppRegExp.isEmailValid(value)) {
      return 'Email is not valid';
    }
    return null;
  }

  static String? validatePassword(Object? context, String? password) {
    final value = password ?? '';
    if (value.trim().isEmpty) {
      return 'Password is required';
    }
    if (!AppRegExp.isPasswordValid(value)) {
      return 'Password must include 8 characters, a number, uppercase letter, and symbol';
    }
    return null;
  }

  static String? validateConfirmPassword(
    Object? context,
    String? password,
    String? confirmPassword,
  ) {
    final value = confirmPassword ?? '';
    if (value.trim().isEmpty) {
      return 'Confirm password is required';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validatePhoneNumber(Object? context, String? phoneNumber) {
    final value = phoneNumber?.trim() ?? '';
    if (value.isEmpty) {
      return 'Phone number is required';
    }
    if (!AppRegExp.isPhoneValid(value)) {
      return 'Phone number is not valid';
    }
    return null;
  }

  static String? validateRequired(Object? context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? validOtp(Object? context, String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) {
      return 'Verification code is required';
    }
    if (code.length < 4) {
      return 'Verification code is invalid';
    }
    return null;
  }
}

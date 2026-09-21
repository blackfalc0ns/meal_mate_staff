import 'package:flutter/widgets.dart';

import '../l10n/translations/app_localizations.dart';
import 'regex.dart';

/// Centralized validation utilities supporting dynamic localization across any language.
///
/// If [context] is provided, validation error messages are localized based on the
/// active locale (Arabic, English, or any additional language added in the future).
/// If [context] is null (e.g. in headless unit tests), fallback English strings are returned.
abstract class Validations {
  static AppLocalizations? _loc(BuildContext? context) {
    if (context == null) return null;
    return AppLocalizations.of(context);
  }

  /// Validates full or first/last names.
  static String? validateName(BuildContext? context, String? name) {
    final l = _loc(context);
    final value = name?.trim() ?? '';
    if (value.isEmpty) {
      return l?.validationNameRequired ?? 'Name is required';
    }
    if (!AppRegExp.isNameValid(value)) {
      return l?.validationNameInvalid ?? 'Name is not valid';
    }
    return null;
  }

  /// Validates email format.
  static String? validateEmail(BuildContext? context, String? email) {
    final l = _loc(context);
    final value = email?.trim() ?? '';
    if (value.isEmpty) {
      return l?.validationEmailRequired ?? 'Email is required';
    }
    if (!AppRegExp.isEmailValid(value)) {
      return l?.validationEmailInvalid ?? 'Email is not valid';
    }
    return null;
  }

  static String? validateOptionalEmail(BuildContext? context, String? email) {
    final value = email?.trim() ?? '';
    if (value.isEmpty) return null;
    return validateEmail(context, value);
  }

  static String? validateNationalId(BuildContext? context, String? value) {
    final l = _loc(context);
    final id = value?.trim() ?? '';
    if (id.isEmpty) {
      return l?.validationCivilIdRequired ?? 'Civil ID is required';
    }
    if (!RegExp(r'^\d{10,14}$').hasMatch(id)) {
      return l?.validationCivilIdInvalid ?? 'Civil ID is not valid';
    }
    return null;
  }

  static String? validateFutureDate(BuildContext? context, String? value) {
    final dateText = value?.trim() ?? '';
    if (dateText.isEmpty) {
      return _loc(context)?.validationFieldRequired ?? 'This field is required';
    }
    final parsed = DateTime.tryParse(dateText.replaceAll('/', '-'));
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final localDate = parsed?.toLocal();
    final parsedCalendarDate = localDate == null
        ? null
        : DateTime(localDate.year, localDate.month, localDate.day);
    if (parsedCalendarDate == null ||
        !parsedCalendarDate.isAfter(startOfToday)) {
      return _loc(context)?.validationFutureDate ??
          'Date must be in the future';
    }
    return null;
  }

  static String? validateOptionalFutureDate(
    BuildContext? context,
    String? value,
  ) {
    if (value == null || value.trim().isEmpty) return null;
    return validateFutureDate(context, value);
  }

  static String? validateManufactureYear(
    BuildContext? context,
    String? value, {
    int? currentYear,
  }) {
    final yearText = value?.trim() ?? '';
    if (yearText.isEmpty) {
      return _loc(context)?.validationFieldRequired ?? 'This field is required';
    }

    final year = int.tryParse(yearText);
    final maximumYear = (currentYear ?? DateTime.now().year) + 1;
    if (year == null || year < 1990 || year > maximumYear) {
      return _loc(context)?.validationManufactureYearRange(maximumYear) ??
          'Year must be between 1990 and $maximumYear';
    }
    return null;
  }

  /// Validates password complexity.
  static String? validatePassword(BuildContext? context, String? password) {
    final l = _loc(context);
    final value = password ?? '';
    if (value.trim().isEmpty) {
      return l?.validationPasswordRequired ?? 'Password is required';
    }
    if (!AppRegExp.isPasswordValid(value)) {
      return l?.validationPasswordInvalid ??
          'Password must include 8 characters, a number, uppercase letter, and symbol';
    }
    return null;
  }

  /// Validates password confirmation matches original password.
  static String? validateConfirmPassword(
    BuildContext? context,
    String? password,
    String? confirmPassword,
  ) {
    final l = _loc(context);
    final value = confirmPassword ?? '';
    if (value.trim().isEmpty) {
      return l?.validationConfirmPasswordRequired ??
          'Confirm password is required';
    }
    if (password != confirmPassword) {
      return l?.validationPasswordsDoNotMatch ?? 'Passwords do not match';
    }
    return null;
  }

  /// Validates phone number format.
  static String? validatePhoneNumber(
    BuildContext? context,
    String? phoneNumber,
  ) {
    final l = _loc(context);
    final value = phoneNumber?.trim() ?? '';
    if (value.isEmpty) {
      return l?.validationPhoneRequired ?? 'Phone number is required';
    }
    if (!AppRegExp.isPhoneValid(value)) {
      return l?.validationPhoneInvalid ?? 'Phone number is not valid';
    }
    return null;
  }

  /// Validates that a required field is not empty.
  static String? validateRequired(
    BuildContext? context,
    String? value, [
    String? customMessage,
  ]) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ??
          _loc(context)?.validationFieldRequired ??
          'This field is required';
    }
    return null;
  }

  /// Validates one-time password (OTP) code.
  static String? validOtp(BuildContext? context, String? value) {
    final l = _loc(context);
    final code = value?.trim() ?? '';
    if (code.isEmpty) {
      return l?.validationOtpRequired ?? 'Verification code is required';
    }
    if (code.length < 4) {
      return l?.validationOtpInvalid ?? 'Verification code is invalid';
    }
    return null;
  }

  /// Validates Civil ID format.
  static String? validateCivilId(BuildContext? context, String? value) {
    final l = _loc(context);
    final code = value?.trim() ?? '';
    if (code.isEmpty) {
      return l?.validationCivilIdRequired ?? 'Civil ID is required';
    }
    if (code.length < 12) {
      return l?.validationCivilIdInvalid ?? 'Civil ID is not valid';
    }
    return null;
  }
}

/// Convenience extensions on [BuildContext] for concise validation calls.
extension ValidationsExtension on BuildContext {
  String? validateName(String? name) => Validations.validateName(this, name);

  String? validateEmail(String? email) =>
      Validations.validateEmail(this, email);

  String? validateOptionalEmail(String? email) =>
      Validations.validateOptionalEmail(this, email);

  String? validateNationalId(String? value) =>
      Validations.validateNationalId(this, value);

  String? validateFutureDate(String? value) =>
      Validations.validateFutureDate(this, value);

  String? validateOptionalFutureDate(String? value) =>
      Validations.validateOptionalFutureDate(this, value);

  String? validateManufactureYear(String? value) =>
      Validations.validateManufactureYear(this, value);

  String? validatePassword(String? password) =>
      Validations.validatePassword(this, password);

  String? validateConfirmPassword(String? password, String? confirmPassword) =>
      Validations.validateConfirmPassword(this, password, confirmPassword);

  String? validatePhoneNumber(String? phoneNumber) =>
      Validations.validatePhoneNumber(this, phoneNumber);

  String? validateRequired(String? value, [String? customMessage]) =>
      Validations.validateRequired(this, value, customMessage);

  String? validOtp(String? value) => Validations.validOtp(this, value);

  String? validateCivilId(String? value) =>
      Validations.validateCivilId(this, value);
}

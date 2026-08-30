import 'package:flutter/material.dart';

import '../../config/theme/colors.dart';
import '../network/failuer_mapper.dart';

enum CustomSnackbarPosition { top, bottom }

class CustomSnackbar {
  const CustomSnackbar._();

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    _show(context, message, AppColors.success, duration);
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    _show(context, message, AppColors.error, duration);
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    _show(context, message, AppColors.warning, duration);
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    _show(context, message, AppColors.primary, duration);
  }

  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    Duration duration,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(mapFailureMessage(context, message)),
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

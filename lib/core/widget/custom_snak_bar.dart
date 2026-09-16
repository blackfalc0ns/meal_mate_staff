import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';

import '../../config/theme/colors.dart';
import '../../config/theme/font_manager.dart';
import '../../config/theme/spacing.dart';
import '../../config/theme/styles_manager.dart';
import '../network/failuer_mapper.dart';

enum CustomSnackbarPosition { top, bottom }

class CustomSnackbar {
  const CustomSnackbar._();

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(milliseconds: 2500),
    CustomSnackbarPosition position = CustomSnackbarPosition.top,
  }) {
    final text = mapFailureMessage(context, message);
    CherryToast.success(
      title: Text(
        text,
        style: getMediumStyle(
          color: AppColors.textPrimary,
          fontSize: FontSize.size13,
        ),
      ),
      toastPosition: position == CustomSnackbarPosition.top
          ? Position.top
          : Position.bottom,
      animationType: position == CustomSnackbarPosition.top
          ? AnimationType.fromTop
          : AnimationType.fromBottom,
      animationDuration: const Duration(milliseconds: 300),
      toastDuration: duration,
      autoDismiss: true,
      borderRadius: Spacing.radiusMd,
      shadowColor: AppColors.shadow.withValues(alpha: 0.15),
    ).show(context);
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(milliseconds: 2500),
    CustomSnackbarPosition position = CustomSnackbarPosition.top,
  }) {
    final text = mapFailureMessage(context, message);
    CherryToast.error(
      title: Text(
        text,
        style: getMediumStyle(
          color: AppColors.textPrimary,
          fontSize: FontSize.size13,
        ),
      ),
      toastPosition: position == CustomSnackbarPosition.top
          ? Position.top
          : Position.bottom,
      animationType: position == CustomSnackbarPosition.top
          ? AnimationType.fromTop
          : AnimationType.fromBottom,
      animationDuration: const Duration(milliseconds: 300),
      toastDuration: duration,
      autoDismiss: true,
      borderRadius: Spacing.radiusMd,
      shadowColor: AppColors.shadow.withValues(alpha: 0.15),
    ).show(context);
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(milliseconds: 2500),
    CustomSnackbarPosition position = CustomSnackbarPosition.top,
  }) {
    final text = mapFailureMessage(context, message);
    CherryToast.warning(
      title: Text(
        text,
        style: getMediumStyle(
          color: AppColors.textPrimary,
          fontSize: FontSize.size13,
        ),
      ),
      toastPosition: position == CustomSnackbarPosition.top
          ? Position.top
          : Position.bottom,
      animationType: position == CustomSnackbarPosition.top
          ? AnimationType.fromTop
          : AnimationType.fromBottom,
      animationDuration: const Duration(milliseconds: 300),
      toastDuration: duration,
      autoDismiss: true,
      borderRadius: Spacing.radiusMd,
      shadowColor: AppColors.shadow.withValues(alpha: 0.15),
    ).show(context);
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(milliseconds: 2500),
    CustomSnackbarPosition position = CustomSnackbarPosition.top,
  }) {
    final text = mapFailureMessage(context, message);
    CherryToast.info(
      title: Text(
        text,
        style: getMediumStyle(
          color: AppColors.textPrimary,
          fontSize: FontSize.size13,
        ),
      ),
      toastPosition: position == CustomSnackbarPosition.top
          ? Position.top
          : Position.bottom,
      animationType: position == CustomSnackbarPosition.top
          ? AnimationType.fromTop
          : AnimationType.fromBottom,
      animationDuration: const Duration(milliseconds: 300),
      toastDuration: duration,
      autoDismiss: true,
      borderRadius: Spacing.radiusMd,
      shadowColor: AppColors.shadow.withValues(alpha: 0.15),
    ).show(context);
  }
}

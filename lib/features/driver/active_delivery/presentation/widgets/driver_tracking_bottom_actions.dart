import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';

class DriverTrackingBottomActions extends StatelessWidget {
  const DriverTrackingBottomActions({
    super.key,
    required this.onConfirmArrival,
    this.onReportDelay,
    this.onReportFailed,
    this.isLoading = false,
  });

  final VoidCallback onConfirmArrival;
  final VoidCallback? onReportDelay;
  final VoidCallback? onReportFailed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return AppButton(
      text: locale.driverConfirmArrivalToCustomerAction,
      icon: Icons.check_circle_rounded,
      iconSize: Spacing.iconSm + 4,
      onPressed: onConfirmArrival,
      isLoading: isLoading,
      height: Spacing.buttonHeight,
      borderRadius: Spacing.cardRadius,
      color: color.primary,
      textColor: color.onPrimary,
      textStyle: getBoldStyle(
        fontSize: FontSize.size15,
        fontFamily: FontConstant.alexandria,
        color: color.onPrimary,
      ),
    );
  }
}

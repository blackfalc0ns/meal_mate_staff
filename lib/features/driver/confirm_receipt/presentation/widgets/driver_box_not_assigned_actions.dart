import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';

class DriverBoxNotAssignedActions extends StatelessWidget {
  const DriverBoxNotAssignedActions({
    super.key,
    required this.onScanAnotherCode,
    required this.onContactRestaurant,
    required this.onReturnToBoxesList,
  });

  final VoidCallback onScanAnotherCode;
  final VoidCallback onContactRestaurant;
  final VoidCallback onReturnToBoxesList;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          text: locale.driverScanAnotherCode,
          onPressed: onScanAnotherCode,
          color: color.primary,
          textColor: color.onPrimary,
          height: Spacing.buttonHeight,
          borderRadius: Spacing.buttonRadius,
          icon: Icons.qr_code_scanner_rounded,
        ),
        const SizedBox(height: Spacing.md),
        AppButton(
          text: locale.driverContactRestaurant,
          onPressed: onContactRestaurant,
          variant: AppButtonVariant.outlined,
          color: color.primary,
          textColor: color.primary,
          height: Spacing.buttonHeight,
          borderRadius: Spacing.buttonRadius,
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: Spacing.base),
        Center(
          child: TextButton(
            onPressed: onReturnToBoxesList,
            child: Text(
              locale.driverReturnToBoxesList,
              style: getBoldStyle(
                color: color.primary,
                fontSize: FontSize.size14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

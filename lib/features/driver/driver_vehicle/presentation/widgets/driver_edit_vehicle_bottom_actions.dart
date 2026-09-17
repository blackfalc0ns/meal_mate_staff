import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';

class DriverEditVehicleBottomActions extends StatelessWidget {
  const DriverEditVehicleBottomActions({
    super.key,
    required this.onSave,
    required this.onCancel,
    this.isLoading = false,
    this.isSaveEnabled = true,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isLoading;
  final bool isSaveEnabled;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      children: [
        // Save Changes Button (Start / Right in RTL)
        Expanded(
          flex: 3,
          child: AppButton(
            text: locale.driverEditVehicleSaveChanges,
            onPressed: (isSaveEnabled && !isLoading) ? onSave : null,
            isLoading: isLoading,
            color: isSaveEnabled
                ? color.primary
                : color.primary.withValues(alpha: 0.35),
            textColor: isSaveEnabled
                ? color.onPrimary
                : color.onPrimary.withValues(alpha: 0.7),
            textStyle: getBoldStyle(
              color: isSaveEnabled
                  ? color.onPrimary
                  : color.onPrimary.withValues(alpha: 0.7),
              fontSize: FontSize.size13,
            ),
            borderRadius: Spacing.cardRadius,
            height: Spacing.buttonHeight,
          ),
        ),
        const SizedBox(width: Spacing.md),
        // Cancel Button (End / Left in RTL)
        Expanded(
          flex: 2,
          child: AppButton(
            text: locale.driverEditVehicleCancel,
            onPressed: onCancel,
            color: color.primary.withValues(alpha: 0.08),
            textColor: color.primary,
            textStyle: getBoldStyle(
              color: color.primary,
              fontSize: FontSize.size13,
            ),
            borderRadius: Spacing.cardRadius,
            height: Spacing.buttonHeight,
          ),
        ),
      ],
    );
  }
}

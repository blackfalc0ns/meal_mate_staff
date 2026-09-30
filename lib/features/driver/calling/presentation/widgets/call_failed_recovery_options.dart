import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class CallFailedRecoveryOptions extends StatelessWidget {
  const CallFailedRecoveryOptions({
    super.key,
    this.onDirectCallPressed,
    this.onReportUnreachablePressed,
    this.onCancelPressed,
  });

  final VoidCallback? onDirectCallPressed;
  final VoidCallback? onReportUnreachablePressed;
  final VoidCallback? onCancelPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: Spacing.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: onDirectCallPressed,
            icon: Icon(
              Icons.phone_in_talk_rounded,
              size: Spacing.iconSm,
              color: color.onPrimary,
            ),
            label: Text(
              locale.driverCallExternalButton,
              style: getBoldStyle(
                fontSize: FontSize.size14,
                color: color.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color.primary,
              foregroundColor: color.onPrimary,
              elevation: Spacing.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.radiusLg),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        SizedBox(
          height: Spacing.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: onReportUnreachablePressed,
            icon: Icon(
              Icons.warning_amber_rounded,
              size: Spacing.iconSm,
              color: color.tertiary,
            ),
            label: Text(
              locale.driverCallReportUnreachableButton,
              style: getBoldStyle(
                fontSize: FontSize.size14,
                color: color.tertiary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: color.tertiary.withValues(alpha: 0.5),
                width: Spacing.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.radiusLg),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        TextButton(
          onPressed: onCancelPressed,
          child: Text(
            locale.driverCallCancel,
            style: getMediumStyle(
              fontSize: FontSize.size14,
              color: color.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

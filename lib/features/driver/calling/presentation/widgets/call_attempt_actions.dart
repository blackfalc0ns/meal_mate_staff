import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class CallAttemptActions extends StatelessWidget {
  const CallAttemptActions({
    super.key,
    this.onCallNowPressed,
    this.onCancelPressed,
  });

  final VoidCallback? onCallNowPressed;
  final VoidCallback? onCancelPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: Spacing.buttonHeight,
            child: OutlinedButton(
              onPressed: onCancelPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: color.outlineVariant,
                  width: Spacing.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusLg),
                ),
              ),
              child: Text(
                locale.driverCallCancel,
                style: getBoldStyle(
                  fontSize: FontSize.size14,
                  color: color.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: Spacing.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: onCallNowPressed,
              icon: Icon(
                Icons.phone_rounded,
                size: Spacing.iconSm,
                color: color.onPrimary,
              ),
              label: Text(
                locale.driverCallNow,
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
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';

class DriverManualCodeButton extends StatelessWidget {
  const DriverManualCodeButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: color.outlineVariant.withValues(alpha: 0.5),
                thickness: Spacing.border,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
              child: Text(
                locale.driverOrDivider,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size12,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: color.outlineVariant.withValues(alpha: 0.5),
                thickness: Spacing.border,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        AppButton(
          text: locale.driverEnterCodeManually,
          onPressed: onPressed,
          variant: AppButtonVariant.outlined,
          isExpanded: true,
          height: Spacing.buttonSmallHeight + 4,
          borderRadius: Spacing.radiusMd,
          color: color.primary,
          textColor: color.primary,
          icon: Icons.keyboard_alt_outlined,
          iconSize: Spacing.iconSm,
          iconGap: Spacing.xs,
          textStyle: getSemiBoldStyle(
            color: color.primary,
            fontSize: FontSize.size13,
          ),
        ),
      ],
    );
  }
}

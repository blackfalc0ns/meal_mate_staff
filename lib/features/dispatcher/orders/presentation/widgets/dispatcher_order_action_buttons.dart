import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';

class DispatcherOrderActionButtons extends StatelessWidget {
  const DispatcherOrderActionButtons({
    super.key,
    this.onAssignPressed,
    this.onDetailsPressed,
  });

  final VoidCallback? onAssignPressed;
  final VoidCallback? onDetailsPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SizedBox(
      width: Spacing.dispatcherActionBtnWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            text: locale.dispatcherAssign,
            icon: Icons.person_add_alt_1_rounded,
            onPressed: onAssignPressed ?? () {},
            color: color.primary,
            textColor: color.onPrimary,
            height: Spacing.dispatcherActionBtnHeight,
            borderRadius: Spacing.buttonSmallRadius,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
            iconSize: Spacing.iconSm - Spacing.xs / 2,
            iconGap: Spacing.xs / 2,
            textStyle: getBoldStyle(
              color: color.onPrimary,
              fontSize: FontSize.size11,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          AppButton(
            text: locale.dispatcherDetails,
            variant: AppButtonVariant.outlined,
            onPressed: onDetailsPressed ?? () {},
            color: color.primary,
            textColor: color.primary,
            height: Spacing.dispatcherActionBtnSmallHeight,
            borderRadius: Spacing.buttonSmallRadius,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
            textStyle: getSemiBoldStyle(
              color: color.primary,
              fontSize: FontSize.size11,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_button.dart';

class AccountStatusActionButtons extends StatelessWidget {
  const AccountStatusActionButtons({
    super.key,
    required this.primaryText,
    required this.secondaryText,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final String primaryText;
  final String secondaryText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          text: primaryText,
          onPressed: onPrimaryPressed,
          height: Spacing.accountStatusButtonHeight,
          borderRadius: Spacing.accountStatusButtonRadius,
          color: color.primary,
          textColor: color.onPrimary,
          textStyle: getBoldStyle(
            color: color.onPrimary,
            fontSize: FontSize.size14,
          ),
        ),
        const SizedBox(height: Spacing.accountStatusButtonGap),
        AppButton(
          text: secondaryText,
          onPressed: onSecondaryPressed,
          variant: AppButtonVariant.outlined,
          height: Spacing.accountStatusButtonHeight,
          borderRadius: Spacing.accountStatusButtonRadius,
          color: color.primary,
          textColor: color.primary,
          textStyle: getBoldStyle(
            color: color.primary,
            fontSize: FontSize.size14,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';

class BoxTrackingReportIssueButton extends StatelessWidget {
  const BoxTrackingReportIssueButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return AppButton(
      text: locale.boxTrackingReportIssue,
      onPressed: onPressed,
      variant: AppButtonVariant.outlined,
      color: color.error,
      textColor: color.error,
      height: Spacing.buttonHeight,
      borderRadius: Spacing.buttonRadius,
      icon: Icons.warning_amber_rounded,
      iconSize: Spacing.iconSm,
      iconGap: Spacing.xs,
      textStyle: getSemiBoldStyle(
        color: color.error,
        fontSize: FontSize.size14,
      ),
    );
  }
}

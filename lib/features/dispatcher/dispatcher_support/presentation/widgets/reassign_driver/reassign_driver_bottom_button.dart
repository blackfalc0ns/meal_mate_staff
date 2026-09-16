import 'package:flutter/material.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/widget/app_button.dart';

class ReassignDriverBottomButton extends StatelessWidget {
  const ReassignDriverBottomButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  final VoidCallback? onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        border: Border(
          top: BorderSide(color: color.outlineVariant, width: Spacing.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          text: locale.reassignDriverConfirm,
          onPressed: isEnabled ? onPressed : null,
          color: color.primary,
          textColor: color.onPrimary,
          height: Spacing.buttonHeight,
          borderRadius: Spacing.buttonRadius,
          textStyle: getBoldStyle(
            color: color.onPrimary,
            fontSize: FontSize.size14,
          ),
        ),
      ),
    );
  }
}

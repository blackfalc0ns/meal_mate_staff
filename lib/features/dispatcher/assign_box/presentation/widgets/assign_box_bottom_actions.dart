import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';

class AssignBoxBottomActions extends StatelessWidget {
  const AssignBoxBottomActions({
    super.key,
    this.onViewBoxPressed,
    this.onConfirmPressed,
  });

  final VoidCallback? onViewBoxPressed;
  final VoidCallback? onConfirmPressed;

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
          top: BorderSide(
            color: color.outlineVariant,
            width: Spacing.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                text: locale.assignBoxViewBox,
                variant: AppButtonVariant.outlined,
                onPressed: onViewBoxPressed,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: AppButton(
                text: locale.assignBoxConfirmAssignment,
                variant: AppButtonVariant.filled,
                onPressed: onConfirmPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

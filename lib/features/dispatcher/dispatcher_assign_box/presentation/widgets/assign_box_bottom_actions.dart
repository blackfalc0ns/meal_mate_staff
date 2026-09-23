import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';

class AssignBoxBottomActions extends StatelessWidget {
  const AssignBoxBottomActions({
    super.key,
    this.onViewBoxPressed,
    this.onConfirmPressed,
    this.isConfirmEnabled = true,
    this.isSubmitting = false,
    this.isViewBoxLoading = false,
  });

  final VoidCallback? onViewBoxPressed;
  final VoidCallback? onConfirmPressed;
  final bool isConfirmEnabled;
  final bool isSubmitting;
  final bool isViewBoxLoading;

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
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                textStyle: getRegularStyle(),
                text: locale.assignBoxConfirmAssignment,
                icon: Icons.near_me_rounded,
                variant: AppButtonVariant.filled,
                isLoading: isSubmitting,
                onPressed:
                    (isConfirmEnabled && !isSubmitting) ? onConfirmPressed : null,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: AppButton(
                textStyle: getRegularStyle(),
                text: locale.assignBoxViewBox,
                icon: Icons.visibility_outlined,
                variant: AppButtonVariant.outlined,
                isLoading: isViewBoxLoading,
                onPressed: !isSubmitting ? onViewBoxPressed : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

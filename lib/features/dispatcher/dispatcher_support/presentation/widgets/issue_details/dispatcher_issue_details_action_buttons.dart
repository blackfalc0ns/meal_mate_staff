import 'package:flutter/material.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';

class DispatcherIssueDetailsActionButtons extends StatelessWidget {
  const DispatcherIssueDetailsActionButtons({
    super.key,
    required this.onAssignReplacementTap,
    required this.onContactDriverTap,
    this.onResolveTap,
    this.canMutate = true,
  });

  final VoidCallback? onAssignReplacementTap;
  final VoidCallback? onContactDriverTap;
  final VoidCallback? onResolveTap;
  final bool canMutate;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.6),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.issueDetailsQuickActions,
            style: getBoldStyle(
              fontSize: FontSize.size12,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            height: Spacing.accountStatusButtonHeight,
            child: ElevatedButton.icon(
              onPressed: canMutate ? onAssignReplacementTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: color.primary,
                foregroundColor: color.onPrimary,
                disabledBackgroundColor: color.onSurface.withValues(alpha: 0.12),
                disabledForegroundColor: color.onSurface.withValues(alpha: 0.38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Spacing.buttonSmallRadius,
                  ),
                ),
                elevation: Spacing.cardElevation,
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: Spacing.iconSm),
              label: Text(
                locale.issueDetailsAssignReplacementDriver,
                style: getBoldStyle(
                  fontSize: FontSize.size12,
                  color: canMutate ? color.onPrimary : color.onSurface.withValues(alpha: 0.38),
                ),
              ),
            ),
          ),
          if (onResolveTap != null) ...[
            const SizedBox(height: Spacing.sm),
            SizedBox(
              width: double.infinity,
              height: Spacing.accountStatusButtonHeight,
              child: ElevatedButton.icon(
                onPressed: canMutate ? onResolveTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.secondary,
                  foregroundColor: color.onSecondary,
                  disabledBackgroundColor: color.onSurface.withValues(alpha: 0.12),
                  disabledForegroundColor: color.onSurface.withValues(alpha: 0.38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Spacing.buttonSmallRadius,
                    ),
                  ),
                  elevation: Spacing.cardElevation,
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: Spacing.iconSm),
                label: Text(
                  locale.issueDetailsResolveIssue,
                  style: getBoldStyle(
                    fontSize: FontSize.size12,
                    color: canMutate ? color.onSecondary : color.onSurface.withValues(alpha: 0.38),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            height: Spacing.accountStatusButtonHeight,
            child: OutlinedButton.icon(
              onPressed: onContactDriverTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: color.primary,
                side: BorderSide(color: color.primary, width: Spacing.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Spacing.buttonSmallRadius,
                  ),
                ),
              ),
              icon: Icon(
                Icons.headset_mic_rounded,
                size: Spacing.iconSm,
                color: color.primary,
              ),
              label: Text(
                locale.issueDetailsContactDriver,
                style: getBoldStyle(
                  fontSize: FontSize.size12,
                  color: color.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

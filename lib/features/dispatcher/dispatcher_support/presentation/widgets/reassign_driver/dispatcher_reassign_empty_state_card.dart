import 'package:flutter/material.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';

class DispatcherReassignEmptyStateCard extends StatelessWidget {
  const DispatcherReassignEmptyStateCard({
    super.key,
    this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xl,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant, width: Spacing.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Spacing.buttonSmallHeight + Spacing.sm,
            height: Spacing.buttonSmallHeight + Spacing.sm,
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_search_rounded,
              size: Spacing.iconLg,
              color: color.primary,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            locale.reassignDriverEmptyTitle,
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            locale.reassignDriverEmptySubtitle,
            style: getRegularStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size12,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: Spacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: Spacing.iconSm),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ],
      ),
    );
  }
}

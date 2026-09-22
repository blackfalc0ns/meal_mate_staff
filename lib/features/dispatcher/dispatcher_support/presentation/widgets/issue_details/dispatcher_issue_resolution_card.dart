import 'package:flutter/material.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/dispatcher_issue_resolution_entity.dart';

class DispatcherIssueResolutionCard extends StatelessWidget {
  const DispatcherIssueResolutionCard({
    super.key,
    required this.resolution,
  });

  final DispatcherIssueResolutionEntity resolution;

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
          color: color.secondary.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.xs),
                decoration: BoxDecoration(
                  color: color.secondaryContainer.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: color.secondary,
                  size: Spacing.iconSm,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                locale.issueDetailsResolutionCardTitle,
                style: getBoldStyle(
                  fontSize: FontSize.size13,
                  color: color.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Divider(color: color.outlineVariant.withValues(alpha: 0.4), height: 1),
          const SizedBox(height: Spacing.sm),

          if (resolution.resolvedBy != null && resolution.resolvedBy!.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  '${locale.issueDetailsResolvedBy}: ',
                  style: getRegularStyle(fontSize: FontSize.size11, color: color.onSurfaceVariant),
                ),
                Text(
                  resolution.resolvedBy!,
                  style: getSemiBoldStyle(fontSize: FontSize.size12, color: color.onSurface),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
          ],

          if (resolution.resolvedActionLabel != null && resolution.resolvedActionLabel!.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  '${locale.issueDetailsResolutionAction}: ',
                  style: getRegularStyle(fontSize: FontSize.size11, color: color.onSurfaceVariant),
                ),
                Text(
                  resolution.resolvedActionLabel!,
                  style: getSemiBoldStyle(fontSize: FontSize.size12, color: color.primary),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
          ],

          if (resolution.resolvedAtText != null && resolution.resolvedAtText!.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  '${locale.issueDetailsResolvedAt}: ',
                  style: getRegularStyle(fontSize: FontSize.size11, color: color.onSurfaceVariant),
                ),
                Text(
                  resolution.resolvedAtText!,
                  style: getRegularStyle(fontSize: FontSize.size11, color: color.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
          ],

          if (resolution.resolutionNotes.isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              '${locale.issueDetailsResolutionNotes}:',
              style: getBoldStyle(fontSize: FontSize.size11, color: color.onSurface),
            ),
            const SizedBox(height: Spacing.xs / 2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: color.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(Spacing.radiusXs),
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.4),
                  width: Spacing.border,
                ),
              ),
              child: Text(
                resolution.resolutionNotes,
                style: getRegularStyle(fontSize: FontSize.size12, color: color.onSurface),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

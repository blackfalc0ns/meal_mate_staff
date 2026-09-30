import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class ReassignmentHeroIllustration extends StatelessWidget {
  const ReassignmentHeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      children: [
        const SizedBox(height: Spacing.sm),
        SizedBox(
          height: 110,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 32,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Icon(
                Icons.arrow_forward_rounded,
                size: Spacing.iconSm,
                color: color.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(width: Spacing.xs),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: color.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(Spacing.radiusLg),
                  border: Border.all(
                    color: color.primary.withValues(alpha: 0.3),
                    width: Spacing.border,
                  ),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: 38,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Icon(
                Icons.arrow_forward_rounded,
                size: Spacing.iconSm,
                color: color.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(width: Spacing.xs),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.tertiary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 32,
                  color: color.tertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.base),
        Text(
          locale.reassignRequestTitle,
          style: getBoldStyle(
            fontSize: FontSize.size18,
            color: color.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Text(
            locale.reassignRequestDescription,
            style: getRegularStyle(
              fontSize: FontSize.size13,
              color: color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

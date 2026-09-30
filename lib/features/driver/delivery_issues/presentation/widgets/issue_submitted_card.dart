import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class IssueSubmittedCard extends StatelessWidget {
  const IssueSubmittedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: color.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 64,
                  color: color.primary,
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 4,
              end: 4,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.tertiary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.surface,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: color.onTertiary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xl),
        Text(
          locale.issueSubmittedTitle,
          style: getBoldStyle(
            fontSize: FontSize.size20,
            color: color.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Text(
            locale.issueSubmittedSubtitle,
            style: getRegularStyle(
              fontSize: FontSize.size14,
              color: color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

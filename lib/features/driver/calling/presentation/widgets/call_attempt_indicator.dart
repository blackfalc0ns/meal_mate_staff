import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class CallAttemptIndicator extends StatelessWidget {
  const CallAttemptIndicator({
    super.key,
    required this.currentAttempt,
    this.totalAttempts = 3,
  });

  final int currentAttempt;
  final int totalAttempts;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          locale.driverCallAttemptsLabel,
          style: getMediumStyle(
            fontSize: FontSize.size12,
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalAttempts, (index) {
            final attemptIndex = index + 1;
            final isCompletedOrActive = attemptIndex <= currentAttempt;
            return Container(
              width: Spacing.sm,
              height: Spacing.sm,
              margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompletedOrActive ? color.primary : color.outlineVariant,
              ),
            );
          }),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: Spacing.iconSm,
              color: color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                locale.driverCallAttemptsFooterNote,
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  fontSize: FontSize.size10,
                  color: color.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

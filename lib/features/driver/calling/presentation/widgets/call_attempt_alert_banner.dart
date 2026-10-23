import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class CallAttemptAlertBanner extends StatelessWidget {
  const CallAttemptAlertBanner({
    super.key,
    required this.attemptNumber,
    this.missedAttemptCount,
    this.isUnreachable,
  });

  final int attemptNumber;
  final int? missedAttemptCount;
  final bool? isUnreachable;

  @override
  Widget build(BuildContext context) {
    if ((missedAttemptCount != null
            ? missedAttemptCount! == 0
            : attemptNumber <= 1) &&
        isUnreachable != true) {
      return const SizedBox.shrink();
    }

    final color = context.colorScheme;
    final locale = context.localization;

    final isError = isUnreachable ?? attemptNumber >= 3;
    final bannerBg = isError
        ? color.errorContainer.withValues(alpha: 0.15)
        : color.tertiaryContainer.withValues(alpha: 0.25);
    final bannerBorder = isError
        ? color.error.withValues(alpha: 0.3)
        : color.tertiary.withValues(alpha: 0.3);
    final iconColor = isError ? color.error : color.tertiary;

    final title = isError
        ? locale.driverCallUnreachableTitle
        : locale.driverCallNoAnswerTitle;
    final subtitle = missedAttemptCount != null
        ? locale.driverCallAttemptCounter(missedAttemptCount!)
        : isError
        ? locale.driverCallUnreachableSubtitle
        : locale.driverCallAttemptCounter(attemptNumber - 1);

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.base),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(color: bannerBorder, width: Spacing.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.phone_missed_rounded,
              color: iconColor,
              size: Spacing.iconSm,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: getBoldStyle(
                    fontSize: FontSize.size12,
                    color: color.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: getRegularStyle(
                    fontSize: FontSize.size10,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: isError
                  ? color.error.withValues(alpha: 0.1)
                  : color.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: Text(
              locale.driverCallNoAnswerBadge,
              style: getMediumStyle(
                fontSize: FontSize.size10,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverProfilePolicyBanner extends StatelessWidget {
  const DriverProfilePolicyBanner({super.key});

  static const double _badgeSize = 32.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final fullTip = locale.driverDeliveryPolicyTip;
    const highlightWordAr = 'يدوياً';
    const highlightWordEn = 'manually';

    InlineSpan buildBodySpan() {
      final highlightWord = fullTip.contains(highlightWordAr)
          ? highlightWordAr
          : (fullTip.contains(highlightWordEn) ? highlightWordEn : null);

      if (highlightWord == null) {
        return TextSpan(
          text: fullTip,
          style: getRegularStyle(
            fontSize: FontSize.size11,
            color: color.onSurfaceVariant,
          ),
        );
      }

      final parts = fullTip.split(highlightWord);
      return TextSpan(
        style: getRegularStyle(
          fontSize: FontSize.size11,
          color: color.onSurfaceVariant,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: highlightWord,
            style: getBoldStyle(
              fontSize: FontSize.size11,
              color: color.secondary,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: color.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.driverDeliveryPolicyTitle,
                  style: getBoldStyle(
                    fontSize: FontSize.size13,
                    color: color.primary,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                RichText(
                  text: buildBodySpan(),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          Container(
            width: _badgeSize,
            height: _badgeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.secondary,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              size: Spacing.iconSm,
              color: color.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

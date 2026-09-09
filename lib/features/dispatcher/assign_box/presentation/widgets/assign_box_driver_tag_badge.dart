import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class AssignBoxDriverTagBadge extends StatelessWidget {
  const AssignBoxDriverTagBadge({
    super.key,
    required this.tagText,
    this.isPrimary = false,
  });

  final String tagText;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final Color surfaceColor;
    final Color textColor;

    switch (tagText) {
      case 'الأقل ضغطاً':
        surfaceColor = color.dispatcherBadgeNewSurface;
        textColor = color.dispatcherBadgeNew;
      case 'مشغول بتسليم':
        surfaceColor = color.dispatcherBadgeHighSurface;
        textColor = color.dispatcherBadgeHigh;
      case 'قريب من العميل':
        surfaceColor = color.infoSurface;
        textColor = color.info;
      default:
        surfaceColor = isPrimary
            ? color.dispatcherSuggestionSurface
            : color.dispatcherBadgeNormalSurface;
        textColor = isPrimary
            ? color.primary
            : color.dispatcherBadgeNormal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm - Spacing.border,
        vertical: Spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          tagText,
          style: getMediumStyle(
            color: textColor,
            fontSize: FontSize.size9,
          ),
        ),
      ),
    );
  }
}

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

    final surfaceColor = isPrimary
        ? color.dispatcherSuggestionSurface
        : color.dispatcherBadgeNormalSurface;
    final textColor = isPrimary
        ? color.primary
        : color.dispatcherBadgeNormal;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: Text(
        tagText,
        style: getMediumStyle(
          color: textColor,
          fontSize: FontSize.size10,
        ),
      ),
    );
  }
}

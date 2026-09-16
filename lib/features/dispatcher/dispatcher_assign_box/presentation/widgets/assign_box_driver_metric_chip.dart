import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class AssignBoxDriverMetricChip extends StatelessWidget {
  const AssignBoxDriverMetricChip({
    super.key,
    required this.text,
    this.icon,
  });

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: Spacing.iconSm,
              color: color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.xs),
          ],
          Text(
            text,
            style: getRegularStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size10,
            ),
          ),
        ],
      ),
    );
  }
}

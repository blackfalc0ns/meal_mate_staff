import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverSettingsSectionCard extends StatelessWidget {
  const DriverSettingsSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section Header with Icon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: Spacing.iconSm + 2, color: color.primary),
              const SizedBox(width: Spacing.sm),
              Text(
                title,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        // Card grouping items
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: color.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(Spacing.cardRadius),
            border: Border.all(color: color.outline, width: Spacing.border),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverSettingsMenuTile extends StatelessWidget {
  const DriverSettingsMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                Icon(icon, size: Spacing.iconSm + 4, color: color.primary),
                const SizedBox(width: Spacing.md),
                Text(
                  title,
                  style: getMediumStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size11,
                  ),
                ),
                const Spacer(),
                if (trailingText != null) ...[
                  Text(
                    trailingText!,
                    style: getRegularStyle(
                      color: color.onSurfaceVariant,
                      fontSize: FontSize.size12,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: Spacing.iconMd,
                  color: color.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: Spacing.border,
            indent: Spacing.base,
            endIndent: Spacing.base,
            color: color.outline,
          ),
      ],
    );
  }
}

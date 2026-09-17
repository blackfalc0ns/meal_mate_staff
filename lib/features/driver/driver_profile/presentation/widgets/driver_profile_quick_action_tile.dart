import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverProfileQuickActionTile extends StatelessWidget {
  const DriverProfileQuickActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  static const double _iconBoxSize = 38;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final effectiveIconColor = isDestructive ? color.error : color.primary;
    final effectiveIconBg = isDestructive
        ? color.errorContainer
        : color.primaryContainer;
    final effectiveTextColor = isDestructive ? color.error : color.onSurface;

    return Material(
      color: color.surface,
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Spacing.cardRadius),
            border: Border.all(
              color: color.outline,
              width: Spacing.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: _iconBoxSize,
                height: _iconBoxSize,
                decoration: BoxDecoration(
                  color: effectiveIconBg,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: Spacing.iconSm,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: getBoldStyle(
                        color: effectiveTextColor,
                        fontSize: FontSize.size13,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    Text(
                      subtitle,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: Spacing.iconXs,
                color: color.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverSupportContactCard extends StatelessWidget {
  const DriverSupportContactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Expanded(
      child: Material(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.base,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              border: Border.all(
                color: color.outlineVariant.withValues(alpha: 0.6),
                width: Spacing.border,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color.primary, size: Spacing.iconMd),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  title,
                  style: getMediumStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size14,
                    color: color.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  value,
                  style: getBoldStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size12,
                    color: color.primary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.border),
                Text(
                  subtitle,
                  style: getRegularStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size10,
                    color: color.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversStatusKpiItem extends StatelessWidget {
  const DispatcherDriversStatusKpiItem({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
  });

  final String title;
  final int count;
  final Widget icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Expanded(
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(width: Spacing.xs),
                    Flexible(
                      child: Text(
                        title,
                        style: getMediumStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size10,
                          color: color.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  '$count',
                  style: getBoldStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size18,
                    color: color.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverMapOrderStatColumn extends StatelessWidget {
  const DriverMapOrderStatColumn({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showArrow = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showArrow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: Spacing.iconXs,
              color: color.onPrimary.withValues(alpha: 0.8),
            ),
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getRegularStyle(
                  fontSize: FontSize.size10,
                  color: color.onPrimary.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: getBoldStyle(
                  fontSize: FontSize.size11,
                  color: color.onPrimary,
                ),
              ),
            ),
            // if (showArrow) ...[
            //   const SizedBox(width: Spacing.xs),
            //   Container(
            //     width: 20,
            //     height: 20,
            //     decoration: BoxDecoration(
            //       color: color.onPrimary,
            //       shape: BoxShape.circle,
            //     ),
            //     child: Center(
            //       child: Icon(
            //         isRtl
            //             ? Icons.chevron_left_rounded
            //             : Icons.chevron_right_rounded,
            //         size: 14,
            //         color: color.primary,
            //       ),
            //     ),
            //   ),
            // ],
          ],
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        child: content,
      );
    }

    return content;
  }
}

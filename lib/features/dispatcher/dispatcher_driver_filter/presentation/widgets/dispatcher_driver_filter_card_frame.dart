import 'package:flutter/material.dart';

import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DispatcherDriverFilterCardFrame extends StatelessWidget {
  const DispatcherDriverFilterCardFrame({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final Widget icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final borderColor = color.outline.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(color: borderColor, width: Spacing.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section Header Strip
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9FE),
              border: Border(
                bottom: BorderSide(color: borderColor, width: Spacing.border),
              ),
            ),
            child: Row(
              children: [
                icon,
                const SizedBox(width: Spacing.xs),
                Flexible(
                  child: Text(
                    title,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Body Content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.sm,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

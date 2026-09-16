import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherMapKpiCard extends StatelessWidget {
  const DispatcherMapKpiCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.label,
    required this.statusColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final int count;
  final String label;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      height: Spacing.dispatcherMapKpiCardHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.dispatcherCardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Spacing.iconMd,
            height: Spacing.iconMd,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: Spacing.iconXs - Spacing.border,
              color: iconColor,
            ),
          ),
          const SizedBox(height: Spacing.border),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count.toString(),
              style: getBoldStyle(
                fontSize: FontSize.size14,
                color: color.onSurface,
              ),
            ),
          ),
          const SizedBox(height: Spacing.border),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: Spacing.border * 5,
                  height: Spacing.border * 5,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Spacing.border * 2),
                Text(
                  label,
                  style: getBoldStyle(
                    fontSize: FontSize.size9,
                    color: color.onSurface,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

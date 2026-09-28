import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverDailySummaryCard extends StatelessWidget {
  const DriverDailySummaryCard({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.borderColor,
  });

  final int count;
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color borderColor;

  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: getBoldStyle(
                  fontSize: FontSize.size16,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Icon(
                icon,
                color: accentColor,
                size: _iconSize,
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: getRegularStyle(
              fontSize: FontSize.size10,
              color: color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

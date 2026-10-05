import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverDailyPerformanceCard extends StatelessWidget {
  const DriverDailyPerformanceCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color.primary, size: _iconSize),
        const SizedBox(width: Spacing.xs),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: getBoldStyle(
                  fontSize: FontSize.size12,
                  color: color.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: getRegularStyle(
                  fontSize: FontSize.size9,
                  color: color.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

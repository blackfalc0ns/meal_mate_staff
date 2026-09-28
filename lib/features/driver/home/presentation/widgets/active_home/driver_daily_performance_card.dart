import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverDailyPerformanceCard extends StatelessWidget {
  const DriverDailyPerformanceCard({
    super.key,
    required this.value,
    required this.label,
    required this.iconAsset,
  });

  final String value;
  final String label;
  final String iconAsset;

  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: color.driverMetricCardBg,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.driverCardBorder,
          width: Spacing.hairline,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: getBoldStyle(
                    fontSize: FontSize.size14,
                    color: color.onSurface,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                SvgPicture.asset(
                  iconAsset,
                  width: _iconSize,
                  height: _iconSize,
                  colorFilter: ColorFilter.mode(
                    color.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
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

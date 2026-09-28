import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';

class DriverDailySummaryCard extends StatelessWidget {
  const DriverDailySummaryCard({
    super.key,
    required this.count,
    required this.label,
    required this.iconAsset,
    required this.backgroundColor,
    required this.textColor,
  });

  final int count;
  final String label;
  final String iconAsset;
  final Color backgroundColor;
  final Color textColor;

  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
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
                  color: textColor,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              SvgPicture.asset(
                iconAsset,
                width: _iconSize,
                height: _iconSize,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: getRegularStyle(
              fontSize: FontSize.size10,
              color: textColor,
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

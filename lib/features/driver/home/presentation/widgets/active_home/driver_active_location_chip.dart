import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverActiveLocationChip extends StatelessWidget {
  const DriverActiveLocationChip({
    super.key,
    required this.location,
  });

  final String location;

  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.driverLocationBg,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.near_me_outlined,
            color: color.primary,
            size: _iconSize,
          ),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              '${locale.driverCurrentLocationLabel}: $location',
              style: getMediumStyle(
                fontSize: FontSize.size11,
                color: color.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

import '../../../../../config/theme/colors.dart';
import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverPerformancePodiumBadge extends StatelessWidget {
  const DriverPerformancePodiumBadge({
    super.key,
    required this.rank,
  });

  final int rank;

  Color _getBadgeColor(int rank, ColorScheme color) {
    switch (rank) {
      case 1:
        return color.warning; // Gold / Yellow
      case 2:
        return color.outline; // Silver
      case 3:
        return color.tertiary; // Bronze
      default:
        return color.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final badgeColor = _getBadgeColor(rank, color);

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: color.surface,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        rank.toString(),
        style: getBoldStyle(
          fontFamily: FontConstant.alexandria,
          fontSize: FontSize.size9,
          color: color.onPrimary,
        ),
      ),
    );
  }
}

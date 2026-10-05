import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverNoAssignedBoxesNoticeCard extends StatelessWidget {
  const DriverNoAssignedBoxesNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: color.primaryContainer,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.driverAssignPersonClock,
            width: Spacing.iconLg + Spacing.xs,
            height: Spacing.iconLg + Spacing.xs,
            colorFilter: ColorFilter.mode(color.primary, BlendMode.srcIn),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.driverNoAssignedBoxesNoticeLine1,
                  style: getMediumStyle(
                    color: color.primary,
                    fontSize: FontSize.size13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.start,
                ),
                Text(
                  locale.driverNoAssignedBoxesNoticeLine2,
                  style: getMediumStyle(
                    color: color.primary,
                    fontSize: FontSize.size13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

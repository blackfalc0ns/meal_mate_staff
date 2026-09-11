import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_details_entity.dart';

class DriverDetailsLocationCard extends StatelessWidget {
  const DriverDetailsLocationCard({
    super.key,
    required this.driver,
    this.onOpenMap,
  });

  final DriverDetailsEntity driver;
  final VoidCallback? onOpenMap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Right side in RTL (Location info)
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppAssets.driverLocationPin,
                      width: Spacing.iconXs,
                      height: Spacing.iconXs,
                      colorFilter: ColorFilter.mode(
                        color.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Flexible(
                      child: Text(
                        locale.driverDetailsLocationTitle,
                        style: getBoldStyle(
                          color: color.onSurface,
                          fontSize: FontSize.size14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  driver.locationStatus,
                  style: getSemiBoldStyle(
                    color: color.primary,
                    fontSize: FontSize.size12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  locale.driverDetailsTimeAgo(driver.locationTimeAgoMinutes),
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  driver.locationStreet,
                  style: getRegularStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  driver.locationArea,
                  style: getRegularStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs),
                OutlinedButton(
                  onPressed: onOpenMap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color.primary,
                    side: BorderSide(
                      color: color.primary,
                      width: Spacing.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Spacing.buttonSmallRadius,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xs,
                      vertical: Spacing.xs / 2,
                    ),
                    minimumSize: const Size(Spacing.zero, Spacing.xxl),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          locale.driverDetailsOpenOnMap,
                          style: getSemiBoldStyle(
                            color: color.primary,
                            fontSize: FontSize.size11,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs / 2),
                        SvgPicture.asset(
                          AppAssets.driverOpenMap,
                          width: Spacing.iconXs,
                          height: Spacing.iconXs,
                          colorFilter: ColorFilter.mode(
                            color.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // 2. Left side in RTL (Map preview)
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              child: Image.asset(
                AppAssets.driverMapPreview,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

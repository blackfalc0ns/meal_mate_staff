import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import '../../domain/entities/driver_current_location_entity.dart';

class DriverDetailsLocationCard extends StatelessWidget {
  const DriverDetailsLocationCard({
    super.key,
    required this.location,
    this.onOpenMap,
    this.onRetryLocation,
    this.mapWidget,
  });

  final DriverCurrentLocationEntity location;
  final VoidCallback? onOpenMap;
  final VoidCallback? onRetryLocation;
  final Widget? mapWidget;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final isOffline = location.latitude == null || location.longitude == null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Location text & actions
          Expanded(
            flex: 3,
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
                if (isOffline) ...[
                  Text(
                    locale.driverDetailsLocationOffline,
                    style: getSemiBoldStyle(
                      color: color.error,
                      fontSize: FontSize.size12,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  AppButton(
                    text: locale.driverDetailsRetryLocation,
                    onPressed: onRetryLocation,
                    variant: AppButtonVariant.outlined,
                    isExpanded: false,
                    height: Spacing.xxl,
                    borderRadius: Spacing.buttonSmallRadius,
                    color: color.primary,
                    textColor: color.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs / 2,
                    ),
                    textStyle: getSemiBoldStyle(
                      color: color.primary,
                      fontSize: FontSize.size11,
                    ),
                  ),
                ] else ...[
                  Text(
                    location.statusBadgeText.isNotEmpty
                        ? location.statusBadgeText
                        : locale.driverDetailsStatusOutForDelivery,
                    style: getSemiBoldStyle(
                      color: color.primary,
                      fontSize: FontSize.size12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (location.timeAgoText.isNotEmpty)
                    Text(
                      location.timeAgoText,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: Spacing.xs),
                  if (location.streetName.isNotEmpty)
                    Text(
                      location.streetName,
                      style: getRegularStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (location.areaName.isNotEmpty)
                    Text(
                      location.areaName,
                      style: getRegularStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: Spacing.xs),
                  AppButton(
                    text: locale.driverDetailsOpenOnMap,
                    onPressed: onOpenMap,
                    variant: AppButtonVariant.outlined,
                    isExpanded: false,
                    height: Spacing.xxl,
                    borderRadius: Spacing.buttonSmallRadius,
                    color: color.primary,
                    textColor: color.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xs,
                      vertical: Spacing.xs / 2,
                    ),
                    iconWidget: SvgPicture.asset(
                      AppAssets.driverOpenMap,
                      width: Spacing.iconXs,
                      height: Spacing.iconXs,
                      colorFilter: ColorFilter.mode(
                        color.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    iconGap: Spacing.xs / 2,
                    textStyle: getSemiBoldStyle(
                      color: color.primary,
                      fontSize: FontSize.size11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // 2. Map container
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              child: isOffline
                  ? Container(
                      height: 130,
                      decoration: BoxDecoration(
                        color: color.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: Border.all(
                          color: color.outlineVariant,
                          width: Spacing.border,
                        ),
                        borderRadius: BorderRadius.circular(Spacing.cardRadius),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(Spacing.sm),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off_rounded,
                            size: Spacing.iconLg,
                            color: color.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            locale.driverDetailsLocationOffline,
                            style: getRegularStyle(
                              color: color.onSurfaceVariant,
                              fontSize: FontSize.size10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : (mapWidget ??
                      Image.asset(
                        AppAssets.driverMapPreview,
                        height: 130,
                        fit: BoxFit.cover,
                      )),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import '../../domain/entities/box_tracking_driver_entity.dart';

class BoxTrackingDriverCard extends StatelessWidget {
  const BoxTrackingDriverCard({
    super.key,
    required this.driver,
    this.onLiveTracking,
    this.onSendMessage,
    this.onCall,
  });

  final BoxTrackingDriverEntity driver;
  final VoidCallback? onLiveTracking;
  final VoidCallback? onSendMessage;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant,
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: Spacing.xl - Spacing.xs,
                    backgroundColor: color.primaryContainer,
                    child: Icon(
                      Icons.person_rounded,
                      color: color.primary,
                      size: Spacing.iconMd,
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: driver.isOnline
                            ? color.tertiary
                            : color.onSurfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.surface,
                          width: Spacing.border * 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      driver.name,
                      style: getBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    Text(
                      driver.id,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: AppButton(
                  text: locale.boxTrackingLiveTrack,
                  onPressed: onLiveTracking,
                  variant: AppButtonVariant.filled,
                  color: color.primary,
                  textColor: color.onPrimary,
                  height: Spacing.buttonSmallHeight,
                  borderRadius: Spacing.buttonSmallRadius,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs,
                  ),
                  icon: Icons.navigation_rounded,
                  iconSize: Spacing.iconXs,
                  iconGap: Spacing.xs / 2,
                  textStyle: getSemiBoldStyle(
                    color: color.onPrimary,
                    fontSize: FontSize.size11,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                flex: 4,
                child: AppButton(
                  text: locale.boxTrackingSendMessage,
                  onPressed: onSendMessage,
                  variant: AppButtonVariant.outlined,
                  color: color.primary,
                  textColor: color.primary,
                  height: Spacing.buttonSmallHeight,
                  borderRadius: Spacing.buttonSmallRadius,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs,
                  ),
                  iconWidget: SvgPicture.asset(
                    AppAssets.driverActionMsg,
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
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                flex: 3,
                child: AppButton(
                  text: locale.boxTrackingCall,
                  onPressed: onCall,
                  variant: AppButtonVariant.outlined,
                  color: color.primary,
                  textColor: color.primary,
                  height: Spacing.buttonSmallHeight,
                  borderRadius: Spacing.buttonSmallRadius,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs,
                  ),
                  iconWidget: SvgPicture.asset(
                    AppAssets.driverActionCall,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_cached_network_image.dart';
import '../../domain/entities/box_tracking_driver_entity.dart';

class BoxTrackingDriverCard extends StatelessWidget {
  const BoxTrackingDriverCard({
    super.key,
    required this.driver,
    this.onLiveTracking,
    this.onSendMessage,
    this.onCall,
  });

  final BoxTrackingDriverEntity? driver;
  final VoidCallback? onLiveTracking;
  final VoidCallback? onSendMessage;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final isAssigned = driver != null;

    final driverName = isAssigned && driver!.fullName.isNotEmpty
        ? driver!.fullName
        : (locale.localeName == 'ar' ? 'غير مسند' : 'Unassigned');

    final driverCode = isAssigned && driver!.driverCode.isNotEmpty
        ? driver!.driverCode
        : '-';

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant, width: Spacing.border),
      ),
      child: Row(
        children: [
          // 1. Avatar with AppCachedNetworkImage
          Container(
            width: Spacing.buttonSmallHeight + Spacing.xs,
            height: Spacing.buttonSmallHeight + Spacing.xs,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isAssigned ? color.primary : color.outlineVariant,
                width: Spacing.border * 2,
              ),
            ),
            padding: const EdgeInsets.all(Spacing.xs / 2),
            child: AppCachedNetworkImage(
              imageUrl: driver?.avatarUrl,
              width: Spacing.buttonSmallHeight,
              height: Spacing.buttonSmallHeight,
              shape: BoxShape.circle,
              fit: BoxFit.cover,
              errorWidget: Center(
                child: Icon(
                  Icons.person_rounded,
                  size: Spacing.iconMd,
                  color: color.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              loadingWidget: Center(
                child: Icon(
                  Icons.person_rounded,
                  size: Spacing.iconMd,
                  color: color.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          // 2. Driver Details (Center)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.boxTrackingDriverRole,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size11,
                  ),
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  driverName,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  driverCode,
                  style: getBoldStyle(
                    color: isAssigned ? color.primary : color.onSurfaceVariant,
                    fontSize: FontSize.size11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.xs),
          // 3. Call action button
          Expanded(
            flex: 2,
            child: Opacity(
              opacity: isAssigned ? 1.0 : 0.4,
              child: InkWell(
                onTap: isAssigned ? onCall : null,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
                child: Container(
                  height: Spacing.buttonHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs / 2,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    border: Border.all(
                      color: color.outlineVariant,
                      width: Spacing.border,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        size: Spacing.iconSm,
                        color: color.primary,
                      ),
                      const SizedBox(height: Spacing.xs / 2),
                      Text(
                        locale.boxTrackingCall,
                        style: getSemiBoldStyle(
                          color: color.primary,
                          fontSize: FontSize.size10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          // 4. Message action button
          Expanded(
            flex: 2,
            child: Opacity(
              opacity: isAssigned ? 1.0 : 0.4,
              child: InkWell(
                onTap: isAssigned ? onSendMessage : null,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
                child: Container(
                  height: Spacing.buttonHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs / 2,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    border: Border.all(
                      color: color.outlineVariant,
                      width: Spacing.border,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_rounded,
                        size: Spacing.iconSm,
                        color: color.primary,
                      ),
                      const SizedBox(height: Spacing.xs / 2),
                      Text(
                        locale.boxTrackingSendMessage,
                        style: getSemiBoldStyle(
                          color: color.primary,
                          fontSize: FontSize.size10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          // 5. Live tracking action button
          Expanded(
            flex: 3,
            child: Opacity(
              opacity: isAssigned ? 1.0 : 0.4,
              child: InkWell(
                onTap: isAssigned ? onLiveTracking : null,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
                child: Container(
                  height: Spacing.buttonHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs / 2,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.primary,
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.driverOpenMap,
                        width: Spacing.iconSm,
                        height: Spacing.iconSm,
                        colorFilter: ColorFilter.mode(
                          color.onPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs / 2),
                      Text(
                        locale.boxTrackingLiveTrack,
                        style: getSemiBoldStyle(
                          color: color.onPrimary,
                          fontSize: FontSize.size10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

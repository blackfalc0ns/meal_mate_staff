import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_map_driver_marker_entity.dart';
import '../../domain/entities/dispatcher_map_driver_status.dart';

class DispatcherMapMarkerItem extends StatelessWidget {
  const DispatcherMapMarkerItem({
    super.key,
    required this.driver,
    this.isSelected = false,
    this.onTap,
  });

  final DispatcherMapDriverMarkerEntity driver;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final Color badgeColor;
    final String statusText;
    final IconData statusIcon;

    switch (driver.status) {
      case DispatcherMapDriverStatus.inDelivery:
        badgeColor = color.success;
        statusText = locale.mapStatusInDelivery;
        statusIcon = Icons.local_shipping_rounded;
      case DispatcherMapDriverStatus.onTheWayToLoad:
        badgeColor = color.warning;
        statusText = locale.mapStatusOnTheWayToLoad;
        statusIcon = Icons.local_shipping_rounded;
      case DispatcherMapDriverStatus.paused:
        badgeColor = color.onSurfaceVariant;
        statusText = locale.mapStatusPaused;
        statusIcon = Icons.pause_rounded;
      case DispatcherMapDriverStatus.hasIssue:
        badgeColor = color.error;
        statusText = locale.mapKpiIssues;
        statusIcon = Icons.warning_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: Spacing.dispatcherMapMarkerAvatarSize,
                height: Spacing.dispatcherMapMarkerAvatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color.primary : color.surface,
                    width: isSelected ? Spacing.border * 2 : Spacing.border,
                  ),
                  boxShadow: [
                    isSelected
                        ? BoxShadow(
                            color: color.shadow.withValues(alpha: 0.6),
                            blurRadius: Spacing.sm,
                            offset: const Offset(0, 2),
                          )
                        : BoxShadow(
                            color: color.shadow.withValues(alpha: 0.2),
                            blurRadius: Spacing.xs,
                            offset: const Offset(0, 1),
                          ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(driver.avatarUrl, fit: BoxFit.cover),
                ),
              ),
              PositionedDirectional(
                bottom: -Spacing.border * 2,
                end: -Spacing.border * 2,
                child: Container(
                  width: Spacing.dispatcherMapMarkerBadgeSize,
                  height: Spacing.dispatcherMapMarkerBadgeSize,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.surface,
                      width: Spacing.border * 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    statusIcon,
                    size: Spacing.iconXs - Spacing.border * 2,
                    color: color.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xs,
              vertical: Spacing.border,
            ),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
              boxShadow: [
                BoxShadow(
                  color: color.shadow.withValues(alpha: 0.1),
                  blurRadius: Spacing.border * 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              driver.boxId,
              style: getBoldStyle(
                fontSize: FontSize.size9,
                color: color.onSurface,
              ),
            ),
          ),
          const SizedBox(height: Spacing.border),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xs,
              vertical: Spacing.border,
            ),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
            ),
            child: Text(
              statusText,
              style: getBoldStyle(
                fontSize: FontSize.size8,
                color: color.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_map_driver_marker_entity.dart';
import '../../domain/entities/dispatcher_map_driver_status.dart';

class DispatcherMapDriverCard extends StatelessWidget {
  const DispatcherMapDriverCard({
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

    final Color statusColor;
    final Color statusBgColor;
    final String statusText;

    switch (driver.status) {
      case DispatcherMapDriverStatus.inDelivery:
        statusColor = color.success;
        statusBgColor = color.success.withValues(alpha: 0.12);
        statusText = locale.mapStatusInDelivery;
      case DispatcherMapDriverStatus.onTheWayToLoad:
        statusColor = color.warning;
        statusBgColor = color.warning.withValues(alpha: 0.12);
        statusText = locale.mapStatusOnTheWayToLoad;
      case DispatcherMapDriverStatus.paused:
        statusColor = color.onSurfaceVariant;
        statusBgColor = color.onSurfaceVariant.withValues(alpha: 0.12);
        statusText = locale.mapStatusPaused;
      case DispatcherMapDriverStatus.hasIssue:
        statusColor = color.error;
        statusBgColor = color.error.withValues(alpha: 0.12);
        statusText = locale.mapKpiIssues;
    }

    final distanceStr = driver.remainingDistanceKm != null
        ? locale.mapRemainingDistanceKm(
            driver.remainingDistanceKm!.toStringAsFixed(1),
          )
        : locale.mapNoDistance;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.dispatcherCardRadius),
      child: Container(
        width: Spacing.dispatcherMapBottomCardWidth,
        height: Spacing.dispatcherMapBottomCardHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.dispatcherCardRadius),
          border: Border.all(
            color: isSelected
                ? color.primary
                : color.outlineVariant.withValues(alpha: 0.6),
            width: isSelected ? Spacing.border * 2 : Spacing.border,
          ),
          boxShadow: [
            BoxShadow(
              color: color.shadow.withValues(alpha: 0.08),
              blurRadius: Spacing.xs,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: Spacing.border * 6,
                  height: Spacing.border * 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Container(
              width: Spacing.dispatcherDriverAvatarSize,
              height: Spacing.dispatcherDriverAvatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: ClipOval(
                child: Image.asset(driver.avatarUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: Spacing.border),
            Text(
              driver.name,
              style: getBoldStyle(
                fontSize: FontSize.size10,
                color: color.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              driver.boxId,
              style: getBoldStyle(
                fontSize: FontSize.size9,
                color: color.primary,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: Spacing.border),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: Spacing.xs,
              ),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
              ),
              child: Text(
                statusText,
                style: getBoldStyle(
                  fontSize: FontSize.size8,
                  color: statusColor,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              locale.mapLocation,
              style: getRegularStyle(
                fontSize: FontSize.size8,
                color: color.onSurfaceVariant,
              ),
            ),
            Text(
              driver.locationName,
              style: getBoldStyle(
                fontSize: FontSize.size9,
                color: color.onSurface,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: Spacing.xs),
            Container(
              width: double.infinity,
              height: Spacing.border,
              color: color.outlineVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: Spacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: Spacing.iconXs - Spacing.border * 2,
                  color: color.primary,
                ),
                const SizedBox(width: Spacing.border),
                Text(
                  distanceStr,
                  style: getBoldStyle(
                    fontSize: FontSize.size9,
                    color: color.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              locale.mapRemainingDistance,
              style: getRegularStyle(
                fontSize: FontSize.size7,
                color: color.onSurfaceVariant,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

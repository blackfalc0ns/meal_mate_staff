import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import '../../domain/entities/driver_map_stop_entity.dart';

class DriverMapStopCard extends StatelessWidget {
  const DriverMapStopCard({
    super.key,
    required this.stop,
    required this.isSelected,
    this.onTap,
  });

  final DriverMapStopEntity stop;
  final bool isSelected;
  final VoidCallback? onTap;

  String _resolveStatusText(BuildContext context) {
    final locale = context.localization;
    if (stop.isDelivered) {
      return locale.driverSummaryDelivered;
    }
    if (stop.sequenceNumber == 1) {
      return locale.driverDetailsStatusOutForDelivery;
    }
    return locale.driverStatusOnTheWayToCustomer;
  }

  Color _resolveStatusColor(BuildContext context) {
    final color = context.colorScheme;
    if (stop.isDelivered) {
      return color.outline;
    }
    if (stop.sequenceNumber == 1) {
      return color.secondaryContainer;
    }
    return color.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final statusText = _resolveStatusText(context);
    final statusColor = _resolveStatusColor(context);

    final footerColor = isSelected ? color.primary : color.outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        isSelected ? Spacing.radiusXl : Spacing.radiusLg,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(
            isSelected ? Spacing.radiusXl : Spacing.radiusLg,
          ),
          border: isSelected
              ? Border.all(color: color.primary, width: 2.0)
              : null,
          boxShadow: [
            BoxShadow(
              color: color.shadow.withValues(alpha: isSelected ? 0.08 : 0.04),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.primary
                      : color.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Text(
                  stop.badgeText,
                  style: getBoldStyle(
                    fontSize: FontSize.size10,
                    color: isSelected ? color.onPrimary : color.primary,
                  ),
                ),
              ),
            ),
            Container(
              width: 46,
              height: 46,
              padding: const EdgeInsets.all(Spacing.xs),
              decoration: BoxDecoration(
                color: color.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: stop.imageAsset.endsWith('.svg')
                    ? SvgPicture.asset(
                        stop.imageAsset,
                        width: 24,
                        height: 24,
                      )
                    : Image.asset(
                        stop.imageAsset,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              stop.customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getBoldStyle(
                fontSize: isSelected ? FontSize.size15 : FontSize.size14,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              stop.boxCode,
              style: getBoldStyle(
                fontSize: FontSize.size12,
                color: color.primary,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 13,
                  color: color.primary,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    stop.area,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getBoldStyle(
                      fontSize: FontSize.size11,
                      color: color.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Flexible(
                    child: Text(
                      statusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getMediumStyle(
                        fontSize: FontSize.size10,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: footerColor,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      stop.deliveryTimeSlot,
                      style: getBoldStyle(
                        fontSize: isSelected
                            ? FontSize.size11
                            : FontSize.size10,
                        color: footerColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      size: 13,
                      color: footerColor,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      '${stop.mealsCount} ${locale.driverMealsUnit}',
                      style: getBoldStyle(
                        fontSize: isSelected
                            ? FontSize.size11
                            : FontSize.size10,
                        color: footerColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

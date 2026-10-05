import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import '../../../orders/domain/entities/driver_delivery_status.dart';
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
    if (stop.statusText != null && stop.statusText!.trim().isNotEmpty) {
      return stop.statusText!.trim();
    }
    final locale = context.localization;
    if (stop.isDelivered) {
      return locale.driverSummaryDelivered;
    }
    if (stop.status == DriverDeliveryStatus.inProgress) {
      return locale.driverDetailsStatusOutForDelivery;
    }
    return locale.driverStatusOnTheWayToCustomer;
  }

  Color _resolveStatusColor(BuildContext context) {
    final color = context.colorScheme;
    final colorStr = stop.statusColor?.replaceAll('#', '').trim().toLowerCase();
    if (colorStr == 'green') return color.success;
    if (colorStr == 'orange') return color.warning;
    if (colorStr == 'gray' || colorStr == 'grey') {
      return color.onSurfaceVariant.withValues(alpha: 0.6);
    }
    if (stop.isDelivered) {
      return color.onSurfaceVariant.withValues(alpha: 0.6);
    }
    if (stop.status == DriverDeliveryStatus.inProgress) {
      return color.success;
    }
    return color.warning;
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final statusText = _resolveStatusText(context);
    final statusColor = _resolveStatusColor(context);

    final footerColor =
        isSelected ? color.primary : color.onSurfaceVariant.withValues(alpha: 0.65);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.radiusXl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusXl),
          border: isSelected
              ? Border.all(color: color.primary, width: 2.0)
              : Border.all(
                  color: color.outline.withValues(alpha: 0.15),
                  width: Spacing.border,
                ),
          boxShadow: [
            BoxShadow(
              color: color.shadow.withValues(alpha: isSelected ? 0.08 : 0.04),
              blurRadius: isSelected ? 14 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: isSelected ? 42 : 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: Spacing.zero,
                    top: Spacing.zero,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.primary
                            : color.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(Spacing.radiusSm),
                      ),
                      child: Text(
                        stop.badgeText,
                        style: getBoldStyle(
                          fontSize: isSelected
                              ? FontSize.size10
                              : FontSize.size9,
                          color: isSelected ? color.onPrimary : color.primary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: isSelected ? 42 : 36,
                    height: isSelected ? 42 : 36,
                    padding: const EdgeInsets.all(Spacing.xs),
                    decoration: BoxDecoration(
                      color: color.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: stop.imageAsset.endsWith('.svg')
                          ? SvgPicture.asset(
                              stop.imageAsset,
                              width: isSelected ? 24 : 20,
                              height: isSelected ? 24 : 20,
                            )
                          : Image.asset(
                              stop.imageAsset,
                              width: isSelected ? 24 : 20,
                              height: isSelected ? 24 : 20,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              stop.customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getBoldStyle(
                fontSize: isSelected ? FontSize.size15 : FontSize.size12,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              stop.boxCode,
              style: getBoldStyle(
                fontSize: isSelected ? FontSize.size12 : FontSize.size10,
                color: color.primary,
              ),
            ),
            const SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppAssets.driverLocationPin,
                  width: isSelected ? 11 : 9,
                  height: isSelected ? 11 : 9,
                  colorFilter: ColorFilter.mode(
                    color.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Flexible(
                  child: Text(
                    stop.area,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getBoldStyle(
                      fontSize: isSelected ? FontSize.size10 : FontSize.size9,
                      color: color.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      statusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getMediumStyle(
                        fontSize: FontSize.size9,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
              child: Divider(
                height: 1,
                thickness: 1,
                color: color.outline.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '${stop.mealsCount} ${locale.driverMealsUnit}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: getBoldStyle(
                            fontSize: isSelected
                                ? FontSize.size10
                                : FontSize.size9,
                            color: footerColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Icon(
                        Icons.flatware_outlined,
                        size: isSelected ? 14 : 12,
                        color: footerColor,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 13,
                  color: color.outline.withValues(alpha: 0.18),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          stop.deliveryTimeSlot,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: getBoldStyle(
                            fontSize: isSelected
                                ? FontSize.size10
                                : FontSize.size9,
                            color: footerColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Icon(
                        Icons.calendar_month_outlined,
                        size: isSelected ? 14 : 12,
                        color: footerColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

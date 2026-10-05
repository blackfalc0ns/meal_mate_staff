import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import '../../../orders/domain/entities/driver_delivery_status.dart';
import '../../domain/entities/driver_map_stop_entity.dart';
import 'driver_map_order_stat_column.dart';

class DriverMapActiveOrderCard extends StatelessWidget {
  const DriverMapActiveOrderCard({
    super.key,
    required this.stop,
    @Deprecated('Customer calling is disabled by operations decision')
    this.onCallPressed,
    this.onAddressPressed,
    this.canNavigate = true,
  });

  final DriverMapStopEntity stop;
  final VoidCallback? onCallPressed;
  final VoidCallback? onAddressPressed;
  final bool canNavigate;

  static Color? _parseStatusColor(String? colorStr) {
    if (colorStr == null) return null;
    final cleaned = colorStr.replaceAll('#', '').trim().toLowerCase();
    if (cleaned.isEmpty) return null;
    if (cleaned == 'green') return const Color(0xFF2E7D32);
    if (cleaned == 'orange') return const Color(0xFFEF6C00);
    if (cleaned == 'gray' || cleaned == 'grey') return const Color(0xFF757575);
    final buffer = StringBuffer();
    if (cleaned.length == 6) {
      buffer.write('ff');
      buffer.write(cleaned);
    } else if (cleaned.length == 8) {
      buffer.write(cleaned);
    } else {
      return null;
    }
    final value = int.tryParse(buffer.toString(), radix: 16);
    return value != null ? Color(value) : null;
  }

  String _resolveStatusText(BuildContext context) {
    if (stop.statusText != null && stop.statusText!.trim().isNotEmpty) {
      return stop.statusText!.trim();
    }
    final locale = context.localization;
    switch (stop.status) {
      case DriverDeliveryStatus.delivered:
        return locale.driverSummaryDelivered;
      case DriverDeliveryStatus.inProgress:
        return locale.driverDetailsStatusOutForDelivery;
      default:
        return locale.driverStatusOnTheWayToCustomer;
    }
  }

  Color _resolveStatusColor(BuildContext context) {
    final parsed = _parseStatusColor(stop.statusColor);
    if (parsed != null) return parsed;
    final color = context.colorScheme;
    switch (stop.status) {
      case DriverDeliveryStatus.delivered:
        return color.onSurfaceVariant;
      case DriverDeliveryStatus.inProgress:
        return color.tertiary;
      default:
        return color.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final statusText = _resolveStatusText(context);
    final statusColor = _resolveStatusColor(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.primary,
        borderRadius: BorderRadius.circular(Spacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.onPrimary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: Spacing.iconMd,
                  color: color.onPrimary,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locale.driverMapCustomerPrefix,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onPrimary.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stop.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getBoldStyle(
                        fontSize: FontSize.size14,
                        color: color.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stop.boxCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getBoldStyle(
                        fontSize: FontSize.size14,
                        color: color.onPrimary,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.25),
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
                                color: color.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.onPrimary.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.driverKpiBox,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      color.onPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            child: Divider(
              color: color.onPrimary.withValues(alpha: 0.15),
              height: 1,
              thickness: 1,
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: DriverMapOrderStatColumn(
                  icon: Icons.location_on_outlined,
                  label: locale.driverAddressLabel,
                  value: stop.formattedAddress,
                  showArrow: canNavigate,
                  onTap: canNavigate ? onAddressPressed : null,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                flex: 3,
                child: DriverMapOrderStatColumn(
                  icon: Icons.calendar_today_outlined,
                  label: locale.driverDeliveryTimeLabel,
                  value: stop.deliveryTimeSlot,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                flex: 3,
                child: DriverMapOrderStatColumn(
                  icon: Icons.restaurant_outlined,
                  label: locale.driverMealsCountLabel,
                  value: '${stop.mealsCount} ${locale.driverMealsUnit}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

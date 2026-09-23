import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_cached_network_image.dart';
import '../../domain/entities/driver_performance_delay_level.dart';
import '../../domain/entities/driver_performance_driver_status.dart';
import '../../domain/entities/driver_performance_record_entity.dart';

class DriverPerformanceDriverRow extends StatelessWidget {
  const DriverPerformanceDriverRow({
    super.key,
    required this.record,
    this.onTap,
  });

  final DriverPerformanceRecordEntity record;
  final VoidCallback? onTap;

  Color _getStatusColor(
    DriverPerformanceDriverStatus status,
    ColorScheme color,
  ) {
    switch (status) {
      case DriverPerformanceDriverStatus.available:
        return color.success;
      case DriverPerformanceDriverStatus.busy:
      case DriverPerformanceDriverStatus.onTheWay:
        return color.warning;
      case DriverPerformanceDriverStatus.onBreak:
        return color.error;
      case DriverPerformanceDriverStatus.unknown:
        return color.onSurfaceVariant;
    }
  }

  Color _getDelayColor(
    DriverPerformanceDelayLevel level,
    int minutes,
    ColorScheme color,
  ) {
    switch (level) {
      case DriverPerformanceDelayLevel.good:
        return color.success;
      case DriverPerformanceDelayLevel.warning:
        return color.warning;
      case DriverPerformanceDelayLevel.critical:
        return color.error;
      case DriverPerformanceDelayLevel.unknown:
        if (minutes <= 10) return color.success;
        if (minutes <= 15) return color.warning;
        return color.error;
    }
  }

  Color _getFailColor(int count, ColorScheme color) {
    if (count == 0) return color.success;
    if (count == 1) return color.warning;
    return color.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final dotKey = record.statusDotColorKey?.trim().toLowerCase();
    final Color statusDotColor;
    if (dotKey == 'green' || dotKey == 'success') {
      statusDotColor = color.success;
    } else if (dotKey == 'orange' || dotKey == 'warning') {
      statusDotColor = color.warning;
    } else if (dotKey == 'red' || dotKey == 'error') {
      statusDotColor = color.error;
    } else {
      statusDotColor = _getStatusColor(record.status, color);
    }

    final delayColorKey = record.avgDelayColor?.trim().toLowerCase();
    final Color delayColor;
    if (delayColorKey == 'green' || delayColorKey == 'success') {
      delayColor = color.success;
    } else if (delayColorKey == 'orange' || delayColorKey == 'warning') {
      delayColor = color.warning;
    } else if (delayColorKey == 'red' || delayColorKey == 'error') {
      delayColor = color.error;
    } else {
      delayColor = _getDelayColor(
        record.delayLevel,
        record.avgDelayMinutes,
        color,
      );
    }

    final failColor = _getFailColor(record.failedDeliveryCount, color);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            // Driver avatar & info
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.primary.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          color: color.surfaceContainerHighest,
                        ),
                        child: ClipOval(
                          child: AppCachedNetworkImage(
                            imageUrl: record.avatarUrl,
                            width: 34,
                            height: 34,
                            shape: BoxShape.circle,
                            errorWidget: Icon(
                              Icons.person,
                              size: 20,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        bottom: 0,
                        end: 0,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: statusDotColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color.surface,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.name,
                          style: getBoldStyle(
                            fontFamily: FontConstant.alexandria,
                            fontSize: FontSize.size11,
                            color: color.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          record.driverCode,
                          style: getRegularStyle(
                            fontFamily: FontConstant.alexandria,
                            fontSize: FontSize.size9,
                            color: color.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Delivered count + %
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    record.deliveredCountText ?? '${record.deliveredCount}',
                    style: getBoldStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size12,
                      color: color.onSurface,
                    ),
                  ),
                  Text(
                    record.deliveredPercentageText ??
                        '(${record.deliveredPercentage.toInt()}%)',
                    style: getMediumStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size9,
                      color: color.success,
                    ),
                  ),
                ],
              ),
            ),

            // Delay
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  record.avgDelayText ??
                      locale.driverPerformanceMinutesShort(
                        record.avgDelayMinutes,
                      ),
                  style: getBoldStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size11,
                    color: delayColor,
                  ),
                ),
              ),
            ),

            // Fail count + %
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    record.failedDeliveryCountText ??
                        '${record.failedDeliveryCount}',
                    style: getBoldStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size12,
                      color: color.onSurface,
                    ),
                  ),
                  Text(
                    record.failedDeliveryPercentageText ??
                        '(${record.failedDeliveryPercentage.toInt()}%)',
                    style: getMediumStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size9,
                      color: failColor,
                    ),
                  ),
                ],
              ),
            ),

            // Rating + Chevron
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded, size: 14, color: color.primary),
                  const SizedBox(width: 2),
                  Text(
                    record.rating.toStringAsFixed(1),
                    style: getBoldStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size11,
                      color: color.onSurface,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs / 2),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: color.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import '../../../../../core/widget/app_cached_network_image.dart';
import '../../../../../config/routing/arguments/dispatcher_driver_details_route_arguments.dart';
import '../../domain/entities/dispatcher_map_driver_entity.dart';
import '../../domain/entities/dispatcher_map_driver_status.dart';

class DispatcherMapDriverBottomSheet extends StatelessWidget {
  const DispatcherMapDriverBottomSheet({
    super.key,
    required this.driver,
    this.onCall,
    this.onViewDetails,
  });

  final DispatcherMapDriverEntity driver;
  final VoidCallback? onCall;
  final VoidCallback? onViewDetails;

  static Future<void> show(
    BuildContext context, {
    required DispatcherMapDriverEntity driver,
    VoidCallback? onCall,
    VoidCallback? onViewDetails,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DispatcherMapDriverBottomSheet(
        driver: driver,
        onCall: onCall,
        onViewDetails: onViewDetails,
      ),
    );
  }

  void _handleNavigateToDetails(BuildContext context) {
    if (onViewDetails != null) {
      onViewDetails!();
      return;
    }

    Navigator.of(context).pop();

    unawaited(
      Navigator.of(context).pushNamed(
        AppRoutes.dispatcherDriverDetails,
        arguments: DispatcherDriverDetailsRouteArgs(driverId: driver.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final Color statusColor;
    final Color statusBgColor;
    final String statusText;

    if (driver.hasIssue ||
        driver.status == DispatcherMapDriverStatus.hasIssue) {
      statusColor = color.error;
      statusBgColor = color.error.withValues(alpha: 0.12);
      statusText = driver.statusText?.isNotEmpty == true
          ? driver.statusText!
          : (isAr ? 'مشكلة تتطلب انتباه' : 'Needs Attention');
    } else {
      switch (driver.status) {
        case DispatcherMapDriverStatus.inDelivery:
          statusColor = color.success;
          statusBgColor = color.success.withValues(alpha: 0.12);
          statusText = driver.statusText?.isNotEmpty == true
              ? driver.statusText!
              : (isAr ? 'في التوصيل' : 'In Delivery');
        case DispatcherMapDriverStatus.onTheWayToLoad:
          statusColor = color.warning;
          statusBgColor = color.warning.withValues(alpha: 0.12);
          statusText = driver.statusText?.isNotEmpty == true
              ? driver.statusText!
              : (isAr ? 'في الطريق للتحميل' : 'On The Way');
        case DispatcherMapDriverStatus.paused:
          statusColor = color.onSurfaceVariant;
          statusBgColor = color.onSurfaceVariant.withValues(alpha: 0.12);
          statusText = driver.statusText?.isNotEmpty == true
              ? driver.statusText!
              : (isAr ? 'متوقف' : 'Paused');
        case DispatcherMapDriverStatus.hasIssue:
          statusColor = color.error;
          statusBgColor = color.error.withValues(alpha: 0.12);
          statusText = driver.statusText?.isNotEmpty == true
              ? driver.statusText!
              : (isAr ? 'مشكلة تتطلب انتباه' : 'Needs Attention');
        case DispatcherMapDriverStatus.unknown:
          statusColor = color.onSurfaceVariant;
          statusBgColor = color.onSurfaceVariant.withValues(alpha: 0.12);
          statusText = driver.statusText?.isNotEmpty == true
              ? driver.statusText!
              : (isAr ? 'غير معروف' : 'Unknown');
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Spacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.15),
            blurRadius: Spacing.md,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: Spacing.base,
        right: Spacing.base,
        top: Spacing.md,
        bottom: MediaQuery.paddingOf(context).bottom + Spacing.base,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: color.outlineVariant.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: Spacing.base),

          // Driver Main Info Card
          Row(
            children: [
              // Avatar with status dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.outlineVariant.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child:
                          driver.avatarUrl != null &&
                              driver.avatarUrl!.startsWith('http')
                          ? AppCachedNetworkImage(
                              imageUrl: driver.avatarUrl!,
                              fit: BoxFit.cover,
                              errorWidget: Icon(
                                Icons.person_rounded,
                                size: Spacing.iconLg,
                                color: color.onSurfaceVariant,
                              ),
                            )
                          : Icon(
                              Icons.person_rounded,
                              size: Spacing.iconLg,
                              color: color.onSurfaceVariant,
                            ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: color.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: Spacing.md),

              // Name and Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name.isNotEmpty
                          ? driver.name
                          : (isAr ? 'سائق غير محدد' : 'Unknown Driver'),
                      style: getBoldStyle(
                        fontSize: FontSize.size16,
                        color: color.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Wrap(
                      spacing: Spacing.xs,
                      runSpacing: Spacing.border,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (driver.driverCode != null &&
                            driver.driverCode!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                Spacing.radiusSm,
                              ),
                            ),
                            child: Text(
                              driver.driverCode!,
                              style: getBoldStyle(
                                fontSize: FontSize.size10,
                                color: color.primary,
                              ),
                            ),
                          ),
                        if (driver.plateNumber != null &&
                            driver.plateNumber!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(
                                Spacing.radiusSm,
                              ),
                            ),
                            child: Text(
                              driver.plateNumber!,
                              style: getMediumStyle(
                                fontSize: FontSize.size10,
                                color: color.onSurfaceVariant,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(
                              Spacing.radiusPill,
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: getBoldStyle(
                              fontSize: FontSize.size10,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.base),

          // Issue Alert Banner (if hasIssue)
          if (driver.hasIssue &&
              driver.issueDescription != null &&
              driver.issueDescription!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: color.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
                border: Border.all(color: color.error.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: color.error,
                    size: Spacing.iconMd,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      driver.issueDescription!,
                      style: getMediumStyle(
                        fontSize: FontSize.size12,
                        color: color.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.base),
          ],

          // Operational Quick Chips Grid
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.inventory_2_outlined,
                  title: isAr ? 'الصندوق' : 'Box',
                  value: driver.boxId.isNotEmpty ? driver.boxId : '—',
                  color: color,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: _InfoCard(
                  icon: Icons.location_on_outlined,
                  title: isAr ? 'المنطقة' : 'Zone',
                  value: driver.locationZone ?? '—',
                  color: color,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: _InfoCard(
                  icon: Icons.route_outlined,
                  title: isAr ? 'المسافة' : 'Distance',
                  value: driver.remainingDistanceText ?? '—',
                  color: color,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: _InfoCard(
                  icon: Icons.speed_outlined,
                  title: isAr ? 'السرعة' : 'Speed',
                  value:
                      '${(driver.speed ?? 0).toInt()} ${isAr ? 'كم/س' : 'km/h'}',
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          // Action Buttons
          AppButton(
            text: isAr ? 'عرض تفاصيل السائق الكاملة' : 'View Driver Details',
            icon: Icons.badge_outlined,
            onPressed: () => _handleNavigateToDetails(context),
          ),
          if (driver.phoneNumber != null && driver.phoneNumber!.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            AppButton(
              text: isAr ? 'اتصال بالسائق' : 'Call Driver',
              variant: AppButtonVariant.outlined,
              icon: Icons.phone_outlined,
              onPressed:
                  onCall ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isAr
                              ? 'الاتصال بـ: ${driver.phoneNumber}'
                              : 'Calling: ${driver.phoneNumber}',
                        ),
                      ),
                    );
                  },
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final ColorScheme color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: Spacing.iconSm, color: color.primary),
          const SizedBox(height: 4),
          Text(
            title,
            style: getRegularStyle(
              fontSize: FontSize.size9,
              color: color.onSurfaceVariant,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: getBoldStyle(
              fontSize: FontSize.size11,
              color: color.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

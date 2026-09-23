import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/box_tracking_entity.dart';
import '../../domain/entities/box_tracking_status.dart';

class BoxTrackingHeaderCard extends StatelessWidget {
  const BoxTrackingHeaderCard({super.key, required this.box});

  final BoxTrackingEntity box;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant, width: Spacing.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 3D Box image container (Start in directionality)
          Container(
            width: Spacing.bottomNavHeight,
            height: Spacing.bottomNavHeight,
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: color.primaryContainer,
              borderRadius: BorderRadius.circular(Spacing.radiusLg),
            ),
            child: Image.asset(AppAssets.driverBox3d, fit: BoxFit.contain),
          ),
          const SizedBox(width: Spacing.sm),
          // 2. Info area (Details + Status & Appointment)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Box ID, Customer, Location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        box.boxCode.isNotEmpty
                            ? (box.boxCode.startsWith('#')
                                  ? box.boxCode
                                  : '#${box.boxCode}')
                            : '#${box.boxId}',
                        style: getBoldStyle(
                          color: color.onSurface,
                          fontSize: FontSize.size16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Spacing.xs / 2),
                      Text(
                        locale.boxTrackingCustomerLabel(box.customerName),
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Spacing.xs / 2),
                      Row(
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
                          Expanded(
                            child: Text(
                              box.deliveryAddress,
                              style: getRegularStyle(
                                color: color.onSurfaceVariant,
                                fontSize: FontSize.size11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                // Status badge & appointment time (End in directionality)
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.infoSurface,
                          borderRadius: BorderRadius.circular(
                            Spacing.radiusPill,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: Spacing.xs + Spacing.border,
                              height: Spacing.xs + Spacing.border,
                              decoration: BoxDecoration(
                                color: color.info,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: Spacing.xs),
                            Flexible(
                              child: Text(
                                box.statusText.isNotEmpty
                                    ? box.statusText
                                    : _statusLabel(box.status, locale),
                                style: getSemiBoldStyle(
                                  color: color.info,
                                  fontSize: FontSize.size11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        locale.driverDetailsAppointment,
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        box.deliveryTime,
                        style: getBoldStyle(
                          color: color.onSurface,
                          fontSize: FontSize.size13,
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
        ],
      ),
    );
  }

  String _statusLabel(BoxTrackingStatus status, dynamic locale) {
    return switch (status) {
      BoxTrackingStatus.readyAtRestaurant => locale.boxTrackingStatusReady,
      BoxTrackingStatus.pickedUpByDriver => locale.boxTrackingStatusPickedUp,
      BoxTrackingStatus.onTheWay => locale.boxTrackingStatusOnTheWay,
      BoxTrackingStatus.delivered => locale.boxTrackingStatusDelivered,
      _ => locale.boxTrackingStatusOnTheWay,
    };
  }
}

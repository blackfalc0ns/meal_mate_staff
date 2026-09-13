import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/box_tracking_entity.dart';

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
        border: Border.all(
          color: color.outlineVariant,
          width: Spacing.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#${box.boxId}',
                      style: getBoldStyle(
                        color: color.primary,
                        fontSize: FontSize.size16,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.xs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Spacing.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            locale.boxTrackingStatusOnTheWay,
                            style: getSemiBoldStyle(
                              color: color.primary,
                              fontSize: FontSize.size11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  locale.boxTrackingCustomerLabel(box.customerName),
                  style: getSemiBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.driverLocationPin,
                      width: Spacing.iconXs,
                      height: Spacing.iconXs,
                      colorFilter: ColorFilter.mode(
                        color.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Expanded(
                      child: Text(
                        box.deliveryAddress,
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs / 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: Spacing.iconXs,
                      color: color.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Text(
                      box.deliveryTime,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Image.asset(
            AppAssets.driverBox3d,
            width: 72,
            height: 72,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

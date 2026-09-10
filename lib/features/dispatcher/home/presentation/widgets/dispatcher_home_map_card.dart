import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_map_driver_pin_entity.dart';

class DispatcherHomeMapCard extends StatelessWidget {
  const DispatcherHomeMapCard({
    super.key,
    required this.pins,
    this.onViewFullMap,
    this.onFocusLocation,
    this.onPinTap,
  });

  final List<DispatcherHomeMapDriverPinEntity> pins;
  final VoidCallback? onViewFullMap;
  final VoidCallback? onFocusLocation;
  final ValueChanged<DispatcherHomeMapDriverPinEntity>? onPinTap;

  Color _getStatusBadgeColor(
    ColorScheme color,
    DispatcherHomePinStatus status,
  ) {
    switch (status) {
      case DispatcherHomePinStatus.inDelivery:
        return color.homeTagDeliveryBg;
      case DispatcherHomePinStatus.onTheWayToLoad:
        return color.homeTagLoadingBg;
      case DispatcherHomePinStatus.paused:
        return color.homeTagPausedBg;
    }
  }

  Color _getStatusTextColor(
    ColorScheme color,
    DispatcherHomePinStatus status,
  ) {
    switch (status) {
      case DispatcherHomePinStatus.inDelivery:
      case DispatcherHomePinStatus.onTheWayToLoad:
        return color.surface;
      case DispatcherHomePinStatus.paused:
        return color.homeTagPausedText;
    }
  }

  Color _getPinVehicleBubbleColor(
    ColorScheme color,
    DispatcherHomePinStatus status,
  ) {
    switch (status) {
      case DispatcherHomePinStatus.inDelivery:
        return color.primary;
      case DispatcherHomePinStatus.onTheWayToLoad:
        return color.error;
      case DispatcherHomePinStatus.paused:
        return color.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color.homeSoftPurpleBg,
                      borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    ),
                    child: Center(
                      child: Image.asset(
                        AppAssets.dispatcherHomeMapIcon,
                        width: 14,
                        height: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale.homeDriversMapTitle,
                          style: getBoldStyle(
                            fontFamily: FontConstant.alexandria,
                            fontSize: FontSize.size10,
                            color: color.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          locale.homeDriversMapSubtitle,
                          style: getRegularStyle(
                            fontFamily: FontConstant.alexandria,
                            fontSize: FontSize.size7,
                            color: color.homeMutedText,
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
            const SizedBox(width: Spacing.xs),
            InkWell(
              onTap: onViewFullMap,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.homeSoftPurpleBg,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAssets.dispatcherHomeMapIcon,
                      width: 12,
                      height: 12,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      locale.homeViewFullMap,
                      style: getSemiBoldStyle(
                        fontFamily: FontConstant.alexandria,
                        fontSize: FontSize.size7,
                        color: color.homeActionIconPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          child: Container(
            height: 185,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              border: Border.all(
                color: color.outlineVariant.withValues(alpha: 0.35),
                width: Spacing.border,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.dispatcherHomeMapBg,
                    fit: BoxFit.cover,
                  ),
                ),
                ...pins.map((pin) {
                  return Align(
                    alignment: FractionalOffset(pin.relativeX, pin.relativeY),
                    child: GestureDetector(
                      onTap: () => onPinTap?.call(pin),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: color.surface,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.shadow.withValues(alpha: 0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    pin.avatarUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              PositionedDirectional(
                                end: -4,
                                bottom: -2,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _getPinVehicleBubbleColor(
                                      color,
                                      pin.status,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: color.surface,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping_rounded,
                                    size: 10,
                                    color: color.surface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: color.surface,
                              borderRadius: BorderRadius.circular(Spacing.radiusXs),
                              boxShadow: [
                                BoxShadow(
                                  color: color.shadow.withValues(alpha: 0.1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              pin.boxCode,
                              style: getBoldStyle(
                                fontFamily: FontConstant.alexandria,
                                fontSize: FontSize.size7 - 2,
                                color: color.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusBadgeColor(color, pin.status),
                              borderRadius: BorderRadius.circular(Spacing.radiusXs),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (pin.status == DispatcherHomePinStatus.paused) ...[
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: color.homeTagPausedDot,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                                Text(
                                  pin.statusText,
                                  style: getBoldStyle(
                                    fontFamily: FontConstant.alexandria,
                                    fontSize: FontSize.size7 - 3,
                                    color: _getStatusTextColor(color, pin.status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                PositionedDirectional(
                  end: Spacing.sm,
                  top: Spacing.sm,
                  child: InkWell(
                    onTap: onFocusLocation,
                    borderRadius: BorderRadius.circular(Spacing.radiusPill),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.shadow.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          AppAssets.dispatcherHomeMapTarget,
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

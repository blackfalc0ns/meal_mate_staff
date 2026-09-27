import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_status_item_entity.dart';
import '../services/driver_contact_launcher.dart';
import 'dispatcher_drivers_status_avatar.dart';
import 'dispatcher_drivers_status_badge.dart';

class DispatcherDriversStatusCard extends StatelessWidget {
  const DispatcherDriversStatusCard({
    super.key,
    required this.driver,
    required this.onToggle,
    this.onTap,
    this.isToggling = false,
    this.contactLauncher,
  });

  final DispatcherDriverStatusItemEntity driver;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onTap;
  final bool isToggling;
  final DriverContactLauncher? contactLauncher;

  DriverContactLauncher get _contactLauncher =>
      contactLauncher ?? const DriverContactLauncherImpl();

  Future<void> _handleCall() async {
    if (driver.phoneNumber == null || driver.phoneNumber!.isEmpty) return;
    await _contactLauncher.launchPhone(driver.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final hasPhone =
        driver.phoneNumber != null && driver.phoneNumber!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.hairline,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                DispatcherDriversStatusAvatar(avatarUrl: driver.avatarUrl),
                const SizedBox(width: Spacing.sm),
                // Driver Name & Code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        driver.name,
                        style: getBoldStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size11,
                          color: color.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Spacing.border),
                      Text(
                        driver.code,
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
                const SizedBox(width: Spacing.xs),
                // Rating Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (driver.rating != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            driver.rating!.toStringAsFixed(1),
                            style: getBoldStyle(
                              fontFamily: FontConstant.alexandria,
                              fontSize: FontSize.size10,
                              color: color.onSurface,
                            ),
                          ),
                          const SizedBox(width: Spacing.border),
                          Icon(
                            Icons.star_rounded,
                            size: Spacing.iconXs,
                            color: color.homeStar,
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.border),
                      Text(
                        driver.ratingsCount != null
                            ? '(${driver.ratingsCount})'
                            : locale.driversStatusRating,
                        style: getRegularStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size9,
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ] else ...[
                      Text(
                        locale.driversStatusNewRating,
                        style: getBoldStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size10,
                          color: color.primary,
                        ),
                      ),
                      const SizedBox(height: Spacing.border),
                      Text(
                        locale.driversStatusRating,
                        style: getRegularStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size9,
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: Spacing.sm),
                // Vehicle Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          driver.vehicleModel?.isNotEmpty == true
                              ? driver.vehicleModel!
                              : (driver.vehicleType?.isNotEmpty == true
                                    ? driver.vehicleType!
                                    : locale.driversStatusVehicleCar),
                          style: getMediumStyle(
                            fontFamily: FontConstant.alexandria,
                            fontSize: FontSize.size10,
                            color: color.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: Spacing.border),
                        Icon(
                          Icons.directions_car_filled_outlined,
                          size: Spacing.iconXs,
                          color: color.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.border),
                    Text(
                      driver.plateNumber,
                      style: getRegularStyle(
                        fontFamily: FontConstant.alexandria,
                        fontSize: FontSize.size8,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: Spacing.sm),
                // Call Action Button
                GestureDetector(
                  onTap: hasPhone ? _handleCall : null,
                  behavior: HitTestBehavior.opaque,
                  child: Tooltip(
                    message: hasPhone
                        ? locale.driversStatusCallAction
                        : locale.driversStatusPhoneNotRegistered,
                    child: Container(
                      padding: const EdgeInsets.all(Spacing.xs),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasPhone
                            ? color.primary.withValues(alpha: 0.1)
                            : color.surfaceContainerHighest.withValues(alpha: 0.3),
                      ),
                      child: Icon(
                        Icons.phone_rounded,
                        size: Spacing.iconXs,
                        color: hasPhone
                            ? color.primary
                            : color.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                // Status Badge
                DispatcherDriversStatusBadge(status: driver.operationalStatus),
                const SizedBox(width: Spacing.xs),
                // Switch / Inline Loader
                GestureDetector(
                  onTap: () {}, // prevent card tap
                  child: isToggling
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : Transform.scale(
                          scale: 0.75,
                          child: Switch.adaptive(
                            value: driver.isAvailable,
                            activeTrackColor: color.primary,
                            activeThumbColor: color.surface,
                            onChanged: onToggle,
                          ),
                        ),
                ),
                // Chevron icon pointing logical forward
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: Spacing.iconXs - 2,
                  color: color.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

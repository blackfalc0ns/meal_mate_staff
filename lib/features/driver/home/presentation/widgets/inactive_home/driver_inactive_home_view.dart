import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/core/widget/app_cached_network_image.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_home_entity.dart';

class DriverInactiveHomeView extends StatelessWidget {
  const DriverInactiveHomeView({super.key, required this.home, this.onRefresh});

  final DriverHomeEntity home;
  final Future<void> Function()? onRefresh;

  static const double _cardRadius = 24.0;
  static const double _innerRadius = 16.0;
  static const double _dotSize = 8.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final statusText = home.currentStatusText.isNotEmpty
        ? home.currentStatusText
        : locale.driverStatusInactive;

    final Widget content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Driver Identity Card (Real driver identity without action controls)
          if (home.driverName.isNotEmpty || home.driverCode.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.cardRadius),
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.5),
                  width: Spacing.hairline,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AppCachedNetworkImage(
                    imageUrl: home.profileImageUrl,
                    width: 46,
                    height: 46,
                    shape: BoxShape.circle,
                    errorWidget: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (home.driverName.isNotEmpty)
                          Text(
                            home.driverName,
                            style: getBoldStyle(
                              fontSize: FontSize.size14,
                              color: color.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (home.driverCode.isNotEmpty)
                          Text(
                            home.driverCode,
                            style: getRegularStyle(
                              fontSize: FontSize.size12,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(Spacing.radiusPill),
                      border: Border.all(
                        color: color.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          statusText,
                          style: getMediumStyle(
                            fontSize: FontSize.size12,
                            color: color.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.base),
          ],

          // Inactive Illustration & Status Card (Read-only, non-clickable)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE9E0FA),
              borderRadius: BorderRadius.circular(_cardRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.driverStartWorkIllustration,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    Spacing.xs,
                    Spacing.md,
                    Spacing.md,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.md,
                      horizontal: Spacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: color.surface,
                      borderRadius: BorderRadius.circular(_innerRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          locale.driverStatusNow,
                          style: getBoldStyle(
                            fontSize: FontSize.size14,
                            color: color.primary,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: _dotSize,
                              height: _dotSize,
                              decoration: BoxDecoration(
                                color: color.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              statusText,
                              style: getBoldStyle(
                                fontSize: FontSize.size18,
                                color: color.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          locale.driverInactiveControlledByManager,
                          style: getRegularStyle(
                            fontSize: FontSize.size13,
                            color: color.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.bottomNavHeight + Spacing.base),
        ],
      ),
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: color.primary,
        child: content,
      );
    }

    return content;
  }
}

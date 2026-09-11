import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_details_entity.dart';

class DriverDetailsProfileCard extends StatelessWidget {
  const DriverDetailsProfileCard({
    super.key,
    required this.driver,
  });

  final DriverDetailsEntity driver;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Avatar circle with purple border and green online dot (Far Right in RTL)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: Spacing.xxxl + Spacing.xs * 2, // 56px
                height: Spacing.xxxl + Spacing.xs * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.primary,
                    width: Spacing.border * 2,
                  ),
                ),
                padding: const EdgeInsets.all(Spacing.xs / 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: Spacing.iconLg,
                    color: color.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
              PositionedDirectional(
                bottom: Spacing.zero,
                end: Spacing.zero,
                child: Container(
                  width: Spacing.sm + Spacing.border,
                  height: Spacing.sm + Spacing.border,
                  decoration: BoxDecoration(
                    color: color.tertiary, // Green
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.surface,
                      width: Spacing.border * 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: Spacing.sm),
          // 2. Driver info text (Next to avatar, flexibly sized)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  driver.name,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  driver.id,
                  style: getSemiBoldStyle(
                    color: color.primary,
                    fontSize: FontSize.size13,
                  ),
                ),
                const SizedBox(height: Spacing.xs / 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        driver.phone,
                        style: getMediumStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size11,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                      const SizedBox(width: Spacing.xs / 2),
                      SvgPicture.asset(
                        AppAssets.driverActionCall,
                        width: Spacing.iconXs,
                        height: Spacing.iconXs,
                        colorFilter: ColorFilter.mode(
                          color.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.xs),
          // 3. Status and live update (Far Left in RTL)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  color: color.tertiaryContainer, // Light green
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                  border: Border.all(
                    color: color.tertiary.withValues(alpha: 0.5),
                    width: Spacing.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locale.driverDetailsStatusAvailable,
                      style: getSemiBoldStyle(
                        color: color.tertiary, // Green text
                        fontSize: FontSize.size11,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Container(
                      width: Spacing.xs * 1.5,
                      height: Spacing.xs * 1.5,
                      decoration: BoxDecoration(
                        color: color.tertiary, // Green dot
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xs / 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    locale.driverDetailsLastUpdatedNow,
                    style: getRegularStyle(
                      color: color.onSurfaceVariant,
                      fontSize: FontSize.size10,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs / 2),
                  SvgPicture.asset(
                    AppAssets.driverLiveSignal,
                    width: Spacing.iconXs,
                    height: Spacing.iconXs,
                    colorFilter: ColorFilter.mode(
                      color.tertiary, // Green signal icon
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

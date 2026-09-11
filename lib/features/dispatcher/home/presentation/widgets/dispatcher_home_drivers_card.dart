import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_top_driver_entity.dart';

class DispatcherHomeDriversCard extends StatelessWidget {
  const DispatcherHomeDriversCard({
    super.key,
    required this.drivers,
    this.onViewAllDrivers,
    this.onDriverTap,
  });

  final List<DispatcherHomeTopDriverEntity> drivers;
  final VoidCallback? onViewAllDrivers;
  final ValueChanged<DispatcherHomeTopDriverEntity>? onDriverTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.35),
          width: Spacing.border,
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.homeSoftPurpleBg,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Center(
                  child: Image.asset(
                    AppAssets.dispatcherHomeChartIcon,
                    width: 14,
                    height: 14,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  locale.homeDriversReviewTitle,
                  style: getBoldStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size9,
                    color: color.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ...drivers.map((driver) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Material(
                color: color.homeDriverItemBg,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                child: InkWell(
                  onTap: () => onDriverTap?.call(driver),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xs,
                      vertical: Spacing.xs / 2,
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            driver.avatarUrl,
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver.name,
                                style: getBoldStyle(
                                  fontFamily: FontConstant.alexandria,
                                  fontSize: FontSize.size8,
                                  color: color.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                driver.badgeText,
                                style: getRegularStyle(
                                  fontFamily: FontConstant.alexandria,
                                  fontSize: FontSize.size7 - 1,
                                  color: color.homeMutedText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: color.homeStar,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              driver.rating.toStringAsFixed(1),
                              style: getBoldStyle(
                                fontFamily: FontConstant.alexandria,
                                fontSize: FontSize.size9,
                                color: color.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          Spacer(),
          Material(
            color: color.homeSoftPurpleBg,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            child: InkWell(
              onTap: onViewAllDrivers,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              child: Container(
                height: 28,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAssets.dispatcherHomeActionAssignDriver,
                      width: 10,
                      height: 10,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      locale.homeViewAllDrivers,
                      style: getBoldStyle(
                        fontFamily: FontConstant.alexandria,
                        fontSize: FontSize.size7,
                        color: color.homeActionIconPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

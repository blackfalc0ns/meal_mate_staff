import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_area_summary_entity.dart';

class DispatcherHomeAreasCard extends StatelessWidget {
  const DispatcherHomeAreasCard({
    super.key,
    required this.areas,
    this.onViewAll,
    this.onAreaTap,
  });

  final List<DispatcherHomeAreaSummaryEntity> areas;
  final VoidCallback? onViewAll;
  final ValueChanged<DispatcherHomeAreaSummaryEntity>? onAreaTap;

  Color _getAreaBgColor(ColorScheme color, DispatcherHomeAreaColorType type) {
    switch (type) {
      case DispatcherHomeAreaColorType.salmiya:
        return color.homeAreaSalmiyaBg;
      case DispatcherHomeAreaColorType.hawally:
        return color.homeAreaHawallyBg;
      case DispatcherHomeAreaColorType.jahra:
        return color.homeAreaJahraBg;
      case DispatcherHomeAreaColorType.capital:
        return color.homeAreaCapitalBg;
    }
  }

  Color _getAreaArrowColor(ColorScheme color, DispatcherHomeAreaColorType type) {
    switch (type) {
      case DispatcherHomeAreaColorType.salmiya:
        return color.error;
      case DispatcherHomeAreaColorType.hawally:
        return color.homeStar;
      case DispatcherHomeAreaColorType.jahra:
        return color.homeTagDeliveryBg;
      case DispatcherHomeAreaColorType.capital:
        return color.homeActionIconPurple;
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
            Row(
              children: [
                Image.asset(
                  AppAssets.dispatcherHomeChartIcon,
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.homeAreaSummaryTitle,
                  style: getBoldStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size10,
                    color: color.onSurface,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: onViewAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    locale.homeViewAll,
                    style: getSemiBoldStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size10,
                      color: color.homeActionIconPurple,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: color.homeActionIconPurple,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: areas.map((area) {
            final bgColor = _getAreaBgColor(color, area.colorType);
            final arrowColor = _getAreaArrowColor(color, area.colorType);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xs / 2),
                child: Material(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  child: InkWell(
                    onTap: () => onAreaTap?.call(area),
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xs,
                        vertical: Spacing.xs / 2,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            area.isIncreasing
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 13,
                            color: arrowColor,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  area.name,
                                  style: getBoldStyle(
                                    fontFamily: FontConstant.alexandria,
                                    fontSize: FontSize.size10,
                                    color: color.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: '${area.ordersCount} ',
                                    style: getBoldStyle(
                                      fontFamily: FontConstant.alexandria,
                                      fontSize: FontSize.size10,
                                      color: color.onSurface,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: locale.homeUnitOrder,
                                        style: getRegularStyle(
                                          fontFamily: FontConstant.alexandria,
                                          fontSize: FontSize.size9 - 1,
                                          color: color.homeMutedText,
                                        ),
                                      ),
                                    ],
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
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

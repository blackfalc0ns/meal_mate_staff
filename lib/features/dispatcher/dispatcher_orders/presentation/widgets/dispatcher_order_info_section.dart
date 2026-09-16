import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_order_entity.dart';

class DispatcherOrderInfoSection extends StatelessWidget {
  const DispatcherOrderInfoSection({super.key, required this.order});

  final DispatcherOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.area,
                style: getSemiBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: Spacing.iconSm,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Flexible(
                    child: Text(
                      order.deliveryTimeWindow,
                      style: getRegularStyle(
                        color: color.onSurface,
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
        const SizedBox(width: Spacing.sm),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.dispatcherTodaysMeals,
                style: getRegularStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant_rounded,
                    size: Spacing.iconSm,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Flexible(
                    child: Text(
                      locale.dispatcherMealsCount(order.mealsCount),
                      style: getBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                locale.dispatcherDistance,
                style: getRegularStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: Spacing.iconSm,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Flexible(
                    child: Text(
                      locale.dispatcherDistanceKm(order.distanceKm),
                      style: getBoldStyle(
                        color: color.onSurface,
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
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversStatusHeader extends StatelessWidget {
  const DispatcherDriversStatusHeader({
    super.key,
    this.restaurantName,
    this.role,
  });

  final String? restaurantName;
  final String? role;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final resolvedRestaurant = restaurantName?.isNotEmpty == true
        ? restaurantName!
        : locale.driversStatusStoreName;
    final resolvedRole = role?.isNotEmpty == true
        ? role!
        : locale.driversStatusRoleDispatcher;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.homeBadgeBg,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person,
                      size: Spacing.iconXs,
                      color: color.homeBadgeText,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      resolvedRole,
                      style: getSemiBoldStyle(
                        fontFamily: FontConstant.alexandria,
                        fontSize: FontSize.size11,
                        color: color.homeBadgeText,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    resolvedRestaurant,
                    style: getMediumStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size12,
                      color: color.onSurface,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Icon(
                    Icons.storefront_outlined,
                    size: Spacing.iconSm,
                    color: color.onSurface,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person,
                size: Spacing.iconLg,
                color: color.onSurface,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driversStatusTitle,
                style: getBoldStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size20,
                  color: color.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            locale.driversStatusSubtitle,
            style: getRegularStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size12,
              color: color.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

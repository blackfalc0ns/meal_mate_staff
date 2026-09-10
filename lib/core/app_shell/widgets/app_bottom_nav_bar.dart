import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/spacing.dart';
import '../../constants/assets.dart';
import '../../extensions/extensions.dart';
import 'app_bottom_nav_item.dart';
import 'meal_mate_nav_logo.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    this.selectedIndex = 0,
    this.onItemSelected,
  });

  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsetsDirectional.only(
          start: Spacing.cardRadius,
          end: Spacing.cardRadius,
          bottom: Spacing.sm,
        ),
        padding: const EdgeInsets.all(Spacing.xs),
        decoration: BoxDecoration(
          color: color.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
          boxShadow: [
            BoxShadow(
              color: color.shadow.withValues(alpha: 0.10),
              offset: const Offset(Spacing.zero, Spacing.xs / 2),
              blurRadius: Spacing.lg,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: AppBottomNavItem(
                icon: MealMateNavLogo(
                  isSelected: selectedIndex == 0,
                ),
                label: locale.navHome,
                isSelected: selectedIndex == 0,
                onTap: () => onItemSelected?.call(0),
              ),
            ),
            Expanded(
              child: AppBottomNavItem(
                icon: SvgPicture.asset(
                  AppAssets.navOrders,
                  width: Spacing.iconMd,
                  height: Spacing.iconMd,
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 1
                        ? color.onPrimary
                        : color.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
                label: locale.navOrders,
                isSelected: selectedIndex == 1,
                onTap: () => onItemSelected?.call(1),
              ),
            ),
            Expanded(
              child: AppBottomNavItem(
                icon: SvgPicture.asset(
                  AppAssets.navDelivery,
                  width: Spacing.iconMd,
                  height: Spacing.iconMd,
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 2
                        ? color.onPrimary
                        : color.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
                label: locale.navDelivery,
                isSelected: selectedIndex == 2,
                onTap: () => onItemSelected?.call(2),
              ),
            ),
            Expanded(
              child: AppBottomNavItem(
                icon: SvgPicture.asset(
                  AppAssets.navSupport,
                  width: Spacing.iconMd,
                  height: Spacing.iconMd,
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 3
                        ? color.onPrimary
                        : color.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
                label: locale.navSupport,
                isSelected: selectedIndex == 3,
                onTap: () => onItemSelected?.call(3),
              ),
            ),
            Expanded(
              child: AppBottomNavItem(
                icon: SvgPicture.asset(
                  AppAssets.navProfile,
                  width: Spacing.iconMd,
                  height: Spacing.iconMd,
                  colorFilter: ColorFilter.mode(
                    selectedIndex == 4
                        ? color.onPrimary
                        : color.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
                label: locale.navAccount,
                isSelected: selectedIndex == 4,
                onTap: () => onItemSelected?.call(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

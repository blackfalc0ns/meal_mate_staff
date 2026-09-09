import 'package:flutter/material.dart';

import '../../../config/theme/spacing.dart';
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
          start: Spacing.md,
          end: Spacing.md,
          bottom: Spacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
          border: Border.all(
            color: color.outline,
            width: Spacing.border,
          ),
          boxShadow: [
            BoxShadow(
              color: color.shadow.withValues(alpha: 0.08),
              offset: const Offset(Spacing.zero, Spacing.xs / 2),
              blurRadius: Spacing.md,
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
                icon: Icon(
                  Icons.receipt_long_outlined,
                  size: Spacing.iconMd - Spacing.xs / 2,
                  color: selectedIndex == 1
                      ? color.onPrimary
                      : color.onSurfaceVariant,
                ),
                label: locale.navOrders,
                isSelected: selectedIndex == 1,
                onTap: () => onItemSelected?.call(1),
              ),
            ),
            Expanded(
              child: AppBottomNavItem(
                icon: Icon(
                  Icons.local_shipping_outlined,
                  size: Spacing.iconMd - Spacing.xs / 2,
                  color: selectedIndex == 2
                      ? color.onPrimary
                      : color.onSurfaceVariant,
                ),
                label: locale.navDelivery,
                isSelected: selectedIndex == 2,
                onTap: () => onItemSelected?.call(2),
              ),
            ),
            Expanded(
              child: AppBottomNavItem(
                icon: Icon(
                  Icons.headset_mic_outlined,
                  size: Spacing.iconMd - Spacing.xs / 2,
                  color: selectedIndex == 3
                      ? color.onPrimary
                      : color.onSurfaceVariant,
                ),
                label: locale.navSupport,
                isSelected: selectedIndex == 3,
                onTap: () => onItemSelected?.call(3),
              ),
            ),
            Expanded(
              child: AppBottomNavItem(
                icon: Icon(
                  Icons.person_outline_rounded,
                  size: Spacing.iconMd - Spacing.xs / 2,
                  color: selectedIndex == 4
                      ? color.onPrimary
                      : color.onSurfaceVariant,
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

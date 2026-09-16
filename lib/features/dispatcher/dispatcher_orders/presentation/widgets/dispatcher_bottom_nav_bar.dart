import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import 'dispatcher_bottom_nav_item.dart';

class DispatcherBottomNavBar extends StatelessWidget {
  const DispatcherBottomNavBar({
    super.key,
    this.selectedIndex = 1,
    this.onItemSelected,
  });

  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border(
          top: BorderSide(color: color.outline, width: Spacing.border),
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.05),
            offset: const Offset(Spacing.zero, -Spacing.xs),
            blurRadius: Spacing.sm,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: DispatcherBottomNavItem(
                icon: Icons.storefront_outlined,
                label: locale.dispatcherNavHome,
                isSelected: selectedIndex == 0,
                onTap: () => onItemSelected?.call(0),
              ),
            ),
            Expanded(
              child: DispatcherBottomNavItem(
                icon: Icons.receipt_long_outlined,
                label: locale.dispatcherNavOrders,
                isSelected: selectedIndex == 1,
                onTap: () => onItemSelected?.call(1),
              ),
            ),
            Expanded(
              child: DispatcherBottomNavItem(
                icon: Icons.local_shipping_outlined,
                label: locale.dispatcherNavDelivery,
                isSelected: selectedIndex == 2,
                onTap: () => onItemSelected?.call(2),
              ),
            ),
            Expanded(
              child: DispatcherBottomNavItem(
                icon: Icons.headset_mic_outlined,
                label: locale.dispatcherNavSupport,
                isSelected: selectedIndex == 3,
                onTap: () => onItemSelected?.call(3),
              ),
            ),
            Expanded(
              child: DispatcherBottomNavItem(
                icon: Icons.person_outline_rounded,
                label: locale.dispatcherNavAccount,
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

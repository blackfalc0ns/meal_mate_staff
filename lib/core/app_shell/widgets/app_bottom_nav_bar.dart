import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/spacing.dart';
import '../../constants/assets.dart';
import '../../extensions/extensions.dart';
import 'app_bottom_nav_item.dart';
import 'meal_mate_nav_logo.dart';

/// Floating bottom navigation used by the main app shell.
///
/// Features frosted-glass transparency for the floating pill container,
/// with the active selected tab highlighted in a primary-colored capsule.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    this.selectedIndex = 0,
    this.currentIndex,
    this.onItemSelected,
    this.onTap,
    this.activeColor,
    this.inactiveColor,
    this.activeBackground,
    this.layoutTextDirection,
  });

  final int selectedIndex;
  final int? currentIndex;
  final ValueChanged<int>? onItemSelected;
  final ValueChanged<int>? onTap;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeBackground;
  final TextDirection? layoutTextDirection;

  static const Color _defaultInactiveColor = Color(0xFF191C1D);

  int get _activeIndex => currentIndex ?? selectedIndex;

  void _handleTap(int index) {
    onTap?.call(index);
    onItemSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final effectiveActiveBg = activeBackground ?? color.primary;
    final effectiveInactiveColor = inactiveColor ?? _defaultInactiveColor;
    final activeIndex = _activeIndex;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Center(
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    offset: Offset(0, 4),
                    blurRadius: 18,
                  ),
                  BoxShadow(
                    color: Color(0x2EFFFFFF),
                    offset: Offset(0, -1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.40),
                        width: 1,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.white.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: SizedBox(
                        height: 66,
                        child: Row(
                          textDirection: layoutTextDirection,
                          children: [
                            Expanded(
                              child: AppBottomNavItem(
                                isSelected: activeIndex == 0,
                                activeBackground: effectiveActiveBg,
                                inactiveColor: effectiveInactiveColor,
                                onTap: () => _handleTap(0),
                                icon: MealMateNavLogo(
                                  isSelected: activeIndex == 0,
                                  size: Spacing.iconMd,
                                  inactiveColor: effectiveInactiveColor,
                                ),
                                label: locale.navHome,
                              ),
                            ),
                            Expanded(
                              child: AppBottomNavItem(
                                isSelected: activeIndex == 1,
                                activeBackground: effectiveActiveBg,
                                inactiveColor: effectiveInactiveColor,
                                onTap: () => _handleTap(1),
                                icon: SvgPicture.asset(
                                  AppAssets.navOrders,
                                  width: Spacing.iconMd,
                                  height: Spacing.iconMd,
                                  colorFilter: ColorFilter.mode(
                                    activeIndex == 1
                                        ? color.onPrimary
                                        : effectiveInactiveColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: locale.navOrders,
                              ),
                            ),
                            Expanded(
                              child: AppBottomNavItem(
                                isSelected: activeIndex == 2,
                                activeBackground: effectiveActiveBg,
                                inactiveColor: effectiveInactiveColor,
                                onTap: () => _handleTap(2),
                                icon: SvgPicture.asset(
                                  AppAssets.navMap,
                                  width: Spacing.iconMd,
                                  height: Spacing.iconMd,
                                  colorFilter: ColorFilter.mode(
                                    activeIndex == 2
                                        ? color.onPrimary
                                        : effectiveInactiveColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: locale.navMap,
                              ),
                            ),
                            Expanded(
                              child: AppBottomNavItem(
                                isSelected: activeIndex == 3,
                                activeBackground: effectiveActiveBg,
                                inactiveColor: effectiveInactiveColor,
                                onTap: () => _handleTap(3),
                                icon: SvgPicture.asset(
                                  AppAssets.navSupport,
                                  width: Spacing.iconMd,
                                  height: Spacing.iconMd,
                                  colorFilter: ColorFilter.mode(
                                    activeIndex == 3
                                        ? color.onPrimary
                                        : effectiveInactiveColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: locale.navSupport,
                              ),
                            ),
                            Expanded(
                              child: AppBottomNavItem(
                                isSelected: activeIndex == 4,
                                activeBackground: effectiveActiveBg,
                                inactiveColor: effectiveInactiveColor,
                                onTap: () => _handleTap(4),
                                icon: SvgPicture.asset(
                                  AppAssets.navProfile,
                                  width: Spacing.iconMd,
                                  height: Spacing.iconMd,
                                  colorFilter: ColorFilter.mode(
                                    activeIndex == 4
                                        ? color.onPrimary
                                        : effectiveInactiveColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: locale.navAccount,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

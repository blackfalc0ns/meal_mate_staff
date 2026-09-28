import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverActiveHomeHeader extends StatelessWidget {
  const DriverActiveHomeHeader({
    super.key,
    this.onNotificationTap,
    this.onMenuTap,
    this.hasUnreadNotifications = true,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final bool hasUnreadNotifications;

  static const double _logoHeight = 28;
  static const double _badgeSize = 8;
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onNotificationTap,
              icon: Icon(
                Icons.notifications_none_rounded,
                color: color.onSurface,
                size: _iconSize,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (hasUnreadNotifications)
              PositionedDirectional(
                top: Spacing.zero,
                end: Spacing.zero,
                child: Container(
                  width: _badgeSize,
                  height: _badgeSize,
                  decoration: BoxDecoration(
                    color: color.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        Image.asset(
          AppAssets.authHeaderLogo,
          height: _logoHeight,
          fit: BoxFit.contain,
        ),
        IconButton(
          onPressed: onMenuTap,
          icon: Icon(
            Icons.menu_rounded,
            color: color.onSurface,
            size: _iconSize,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

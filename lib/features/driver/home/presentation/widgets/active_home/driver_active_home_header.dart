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

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onNotificationTap,
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.5),
                  width: Spacing.hairline,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_rounded,
                    color: Color(0xFF1E293B),
                    size: 22,
                  ),
                  if (hasUnreadNotifications)
                    Positioned(
                      top: 10,
                      right: 11,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: color.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Image.asset(
            AppAssets.authHeaderLogo,
            height: _logoHeight,
            fit: BoxFit.contain,
          ),
          IconButton(
            onPressed: onMenuTap,
            icon: Icon(Icons.menu_rounded, color: color.onSurface, size: 28),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

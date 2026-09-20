import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_notification_entity.dart';
import '../../domain/entities/driver_notification_type.dart';

class DriverNotificationCard extends StatelessWidget {
  const DriverNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  final DriverNotificationEntity notification;
  final VoidCallback? onTap;

  static const double _iconBoxSize = 40;
  static const double _unreadDotSize = 7;

  IconData _getIcon() {
    switch (notification.type) {
      case DriverNotificationType.newOrder:
        return Icons.inventory_2_outlined;
      case DriverNotificationType.delivered:
        return Icons.check_circle_outline_rounded;
      case DriverNotificationType.earnings:
        return Icons.account_balance_wallet_outlined;
      case DriverNotificationType.rating:
        return Icons.star_outline_rounded;
      case DriverNotificationType.offer:
        return Icons.card_giftcard_rounded;
      case DriverNotificationType.system:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getIconColor(ColorScheme color) {
    switch (notification.type) {
      case DriverNotificationType.newOrder:
      case DriverNotificationType.offer:
        return color.primary;
      case DriverNotificationType.delivered:
        return color.tertiary;
      case DriverNotificationType.earnings:
      case DriverNotificationType.rating:
        return color.secondary;
      case DriverNotificationType.system:
        return color.error;
    }
  }

  Color _getIconBgColor(ColorScheme color) {
    switch (notification.type) {
      case DriverNotificationType.newOrder:
      case DriverNotificationType.offer:
        return color.primaryContainer;
      case DriverNotificationType.delivered:
        return color.tertiaryContainer;
      case DriverNotificationType.earnings:
      case DriverNotificationType.rating:
        return color.secondaryContainer;
      case DriverNotificationType.system:
        return color.errorContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final icon = _getIcon();
    final iconColor = _getIconColor(color);
    final iconBg = _getIconBgColor(color);

    return Material(
      color: color.surface,
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Spacing.cardRadius),
            border: Border.all(color: color.outline, width: Spacing.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _iconBoxSize,
                height: _iconBoxSize,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: Spacing.iconSm),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: getBoldStyle(
                              color: color.onSurface,
                              fontSize: FontSize.size13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              notification.time,
                              style: getRegularStyle(
                                color: color.onSurfaceVariant,
                                fontSize: FontSize.size10,
                              ),
                            ),
                            if (!notification.isRead) ...[
                              const SizedBox(width: Spacing.xs),
                              Container(
                                width: _unreadDotSize,
                                height: _unreadDotSize,
                                decoration: BoxDecoration(
                                  color: color.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    Text(
                      notification.body,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

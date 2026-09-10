import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_notification_entity.dart';

class DispatcherNotificationCard extends StatelessWidget {
  const DispatcherNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  final DispatcherNotificationEntity notification;
  final VoidCallback? onTap;

  Color _getAvatarBackgroundColor(
    ColorScheme color,
    DispatcherNotificationType type,
  ) {
    switch (type) {
      case DispatcherNotificationType.newBox:
      case DispatcherNotificationType.driverCompleted:
      case DispatcherNotificationType.tripUpdate:
        return color.notificationIconPurpleSurface;
      case DispatcherNotificationType.boxProblem:
      case DispatcherNotificationType.delayedBox:
        return color.notificationIconRedSurface;
      case DispatcherNotificationType.replacementBox:
        return color.notificationIconGreenSurface;
      case DispatcherNotificationType.performanceAlert:
        return color.notificationIconOrangeSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final cardBackground = notification.isUnread
        ? color.notificationCardUnreadSurface
        : color.surface;
    final timeColor = notification.isUnread
        ? color.primary
        : color.onSurfaceVariant;
    final avatarBg = _getAvatarBackgroundColor(color, notification.type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm + Spacing.xs / 2,
        ),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          border: Border.all(
            color: color.notificationCardBorder,
            width: Spacing.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: Spacing.xxxl - Spacing.xs,
                  height: Spacing.xxxl - Spacing.xs,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    notification.iconAsset,
                    width: Spacing.iconMd + Spacing.xs / 2,
                    height: Spacing.iconMd + Spacing.xs / 2,
                    fit: BoxFit.contain,
                  ),
                ),
                if (notification.isUnread)
                  PositionedDirectional(
                    top: 0,
                    start: 0,
                    child: Container(
                      width: Spacing.md - Spacing.border * 2,
                      height: Spacing.md - Spacing.border * 2,
                      decoration: BoxDecoration(
                        color: color.notificationUnreadDot,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.surface,
                          width: Spacing.border,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: getBoldStyle(
                      fontSize: FontSize.size12,
                      color: color.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Spacing.xs / 2),
                  Text(
                    notification.description,
                    style: getRegularStyle(
                      fontSize: FontSize.size10,
                      color: color.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Spacing.xs / 2),
                  Text(
                    notification.timeAgo,
                    style: getBoldStyle(
                      fontSize: FontSize.size10,
                      color: timeColor,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: Spacing.iconSm - Spacing.xs,
              color: color.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

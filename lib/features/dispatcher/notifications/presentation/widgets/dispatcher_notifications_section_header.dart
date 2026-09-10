import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherNotificationsSectionHeader extends StatelessWidget {
  const DispatcherNotificationsSectionHeader({
    super.key,
    this.onMarkAllAsRead,
  });

  final VoidCallback? onMarkAllAsRead;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              locale.notificationsSectionRecent,
              style: getBoldStyle(
                fontSize: FontSize.size12,
                color: color.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          InkWell(
            onTap: onMarkAllAsRead,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.notificationCheckCircle,
                  width: Spacing.iconSm,
                  height: Spacing.iconSm,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.notificationsMarkAllAsRead,
                  style: getMediumStyle(
                    fontSize: FontSize.size11,
                    color: color.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

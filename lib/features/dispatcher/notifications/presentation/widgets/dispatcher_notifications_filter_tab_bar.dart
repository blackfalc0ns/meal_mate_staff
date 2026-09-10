import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_notification_filter_type.dart';

class DispatcherNotificationsFilterTabBar extends StatelessWidget {
  const DispatcherNotificationsFilterTabBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.allCount = 12,
    this.unreadCount = 5,
  });

  final DispatcherNotificationFilterType selectedFilter;
  final ValueChanged<DispatcherNotificationFilterType> onFilterChanged;
  final int allCount;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      height: Spacing.buttonSmallHeight,
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
      padding: const EdgeInsets.all(Spacing.xs / 2),
      decoration: BoxDecoration(
        color: color.notificationPillsBackground,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.notificationPillsBorder,
          width: Spacing.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onFilterChanged(DispatcherNotificationFilterType.all),
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                decoration: BoxDecoration(
                  color: selectedFilter == DispatcherNotificationFilterType.all
                      ? color.surface
                      : color.transparent,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  border: selectedFilter == DispatcherNotificationFilterType.all
                      ? Border.all(
                          color: color.primary,
                          width: Spacing.border,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        locale.notificationsTabAll,
                        style: selectedFilter ==
                                DispatcherNotificationFilterType.all
                            ? getBoldStyle(
                                fontSize: FontSize.size10,
                                color: color.primary,
                              )
                            : getRegularStyle(
                                fontSize: FontSize.size10,
                                color: color.onSurfaceVariant,
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xs,
                        vertical: Spacing.border / 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$allCount',
                        style: getBoldStyle(
                          fontSize: FontSize.size8,
                          color: color.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () =>
                  onFilterChanged(DispatcherNotificationFilterType.unread),
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                decoration: BoxDecoration(
                  color: selectedFilter ==
                          DispatcherNotificationFilterType.unread
                      ? color.surface
                      : color.transparent,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  border: selectedFilter ==
                          DispatcherNotificationFilterType.unread
                      ? Border.all(
                          color: color.primary,
                          width: Spacing.border,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        locale.notificationsTabUnread,
                        style: selectedFilter ==
                                DispatcherNotificationFilterType.unread
                            ? getBoldStyle(
                                fontSize: FontSize.size10,
                                color: color.primary,
                              )
                            : getRegularStyle(
                                fontSize: FontSize.size10,
                                color: color.onSurfaceVariant,
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xs,
                        vertical: Spacing.border / 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: getBoldStyle(
                          fontSize: FontSize.size8,
                          color: color.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: Spacing.border,
            height: Spacing.md,
            color: color.notificationPillsBorder,
          ),
          Expanded(
            child: InkWell(
              onTap: () =>
                  onFilterChanged(DispatcherNotificationFilterType.archive),
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                decoration: BoxDecoration(
                  color: selectedFilter ==
                          DispatcherNotificationFilterType.archive
                      ? color.surface
                      : color.transparent,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  border: selectedFilter ==
                          DispatcherNotificationFilterType.archive
                      ? Border.all(
                          color: color.primary,
                          width: Spacing.border,
                        )
                      : null,
                ),
                child: Text(
                  locale.notificationsTabArchive,
                  style: selectedFilter ==
                          DispatcherNotificationFilterType.archive
                      ? getBoldStyle(
                          fontSize: FontSize.size10,
                          color: color.primary,
                        )
                      : getRegularStyle(
                          fontSize: FontSize.size10,
                          color: color.onSurfaceVariant,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../domain/entities/driver_notification_entity.dart';
import '../../domain/entities/driver_notification_filter_type.dart';
import '../../domain/fake_data/driver_notifications_fake_data.dart';
import '../widgets/driver_notification_card.dart';
import '../widgets/driver_notifications_filter_tab_bar.dart';
import '../widgets/driver_notifications_header.dart';
import '../widgets/driver_notifications_mark_all_button.dart';
import '../widgets/driver_notifications_section_header.dart';

class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({
    super.key,
    this.initialNotifications,
    this.onBack,
    this.onSettingsTap,
  });

  final List<DriverNotificationEntity>? initialNotifications;
  final VoidCallback? onBack;
  final VoidCallback? onSettingsTap;

  @override
  State<DriverNotificationsScreen> createState() =>
      _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  DriverNotificationFilterType _selectedFilter =
      DriverNotificationFilterType.all;
  late List<DriverNotificationEntity> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.of(
      widget.initialNotifications ??
          DriverNotificationsFakeData.defaultNotifications,
    );
  }

  List<DriverNotificationEntity> get _filteredNotifications {
    if (_selectedFilter == DriverNotificationFilterType.all) {
      return _notifications;
    }
    return _notifications
        .where((n) => n.filterCategory == _selectedFilter)
        .toList();
  }

  void _handleFilterChanged(DriverNotificationFilterType filter) {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
    }
  }

  void _handleNotificationTap(DriverNotificationEntity notification) {
    if (!notification.isRead) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    }
  }

  void _handleMarkAllRead() {
    final hasUnread = _notifications.any((n) => !n.isRead);
    if (!hasUnread) return;

    setState(() {
      _notifications = _notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();
    });

    final locale = context.localization;
    CustomSnackbar.showSuccess(
      context: context,
      message: locale.driverNotificationsMarkedAllReadSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final filtered = _filteredNotifications;
    final todayNotifications = filtered.where((n) => n.isToday).toList();
    final yesterdayNotifications = filtered.where((n) => !n.isToday).toList();

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DriverNotificationsHeader(
        onBack: widget.onBack,
        onSettingsTap: widget.onSettingsTap,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DriverNotificationsFilterTabBar(
              selectedFilter: _selectedFilter,
              onFilterChanged: _handleFilterChanged,
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        locale.driverNotificationsEmpty,
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size14,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.base,
                        vertical: Spacing.sm,
                      ),
                      children: [
                        if (todayNotifications.isNotEmpty) ...[
                          DriverNotificationsSectionHeader(
                            title: locale.driverNotificationsSectionToday,
                          ),
                          const SizedBox(height: Spacing.xs),
                          for (final notification in todayNotifications) ...[
                            DriverNotificationCard(
                              notification: notification,
                              onTap: () => _handleNotificationTap(notification),
                            ),
                            const SizedBox(height: Spacing.sm),
                          ],
                        ],
                        if (yesterdayNotifications.isNotEmpty) ...[
                          const SizedBox(height: Spacing.xs),
                          DriverNotificationsSectionHeader(
                            title: locale.driverNotificationsSectionYesterday,
                          ),
                          const SizedBox(height: Spacing.xs),
                          for (final notification
                              in yesterdayNotifications) ...[
                            DriverNotificationCard(
                              notification: notification,
                              onTap: () => _handleNotificationTap(notification),
                            ),
                            const SizedBox(height: Spacing.sm),
                          ],
                        ],
                        const SizedBox(height: Spacing.md),
                        DriverNotificationsMarkAllButton(
                          onPressed: _handleMarkAllRead,
                        ),
                        const SizedBox(height: Spacing.base),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

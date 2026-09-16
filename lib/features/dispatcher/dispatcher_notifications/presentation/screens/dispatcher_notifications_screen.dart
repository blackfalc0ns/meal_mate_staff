import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/app_shell/widgets/app_bottom_nav_bar.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_notification_entity.dart';
import '../../domain/entities/dispatcher_notification_filter_type.dart';
import '../../domain/fake_data/dispatcher_notifications_fake_data.dart';
import '../widgets/dispatcher_notifications_app_bar.dart';
import '../widgets/dispatcher_notifications_filter_tab_bar.dart';
import '../widgets/dispatcher_notifications_list.dart';
import '../widgets/dispatcher_notifications_section_header.dart';

class DispatcherNotificationsScreen extends StatefulWidget {
  const DispatcherNotificationsScreen({
    super.key,
    this.showBottomNavBar = false,
    this.onNotificationTap,
    this.onFilterTap,
  });

  final bool showBottomNavBar;
  final ValueChanged<DispatcherNotificationEntity>? onNotificationTap;
  final VoidCallback? onFilterTap;

  @override
  State<DispatcherNotificationsScreen> createState() =>
      _DispatcherNotificationsScreenState();
}

class _DispatcherNotificationsScreenState
    extends State<DispatcherNotificationsScreen> {
  DispatcherNotificationFilterType _selectedFilter =
      DispatcherNotificationFilterType.all;
  late List<DispatcherNotificationEntity> _notifications;
  int _selectedBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _notifications = List.of(DispatcherNotificationsFakeData.notifications);
  }

  List<DispatcherNotificationEntity> get _filteredNotifications {
    switch (_selectedFilter) {
      case DispatcherNotificationFilterType.all:
        return _notifications.where((item) => !item.isArchived).toList();
      case DispatcherNotificationFilterType.unread:
        return _notifications
            .where((item) => item.isUnread && !item.isArchived)
            .toList();
      case DispatcherNotificationFilterType.archive:
        return _notifications.where((item) => item.isArchived).toList();
    }
  }

  int get _allCount =>
      _notifications.where((item) => !item.isArchived).length;

  int get _unreadCount =>
      _notifications.where((item) => item.isUnread).length;

  void _onFilterChanged(DispatcherNotificationFilterType filter) {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
    }
  }

  void _onMarkAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((item) => item.copyWith(isUnread: false))
          .toList();
    });
  }

  void _handleNotificationTap(DispatcherNotificationEntity item) {
    if (item.isUnread) {
      setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == item.id) {
            return n.copyWith(isUnread: false);
          }
          return n;
        }).toList();
      });
    }
    widget.onNotificationTap?.call(item);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      extendBody: widget.showBottomNavBar,
      appBar: DispatcherNotificationsAppBar(
        onFilterPressed: widget.onFilterTap,
      ),
      body: SafeArea(
        bottom: !widget.showBottomNavBar,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Spacing.xs),
              DispatcherNotificationsFilterTabBar(
                selectedFilter: _selectedFilter,
                onFilterChanged: _onFilterChanged,
                allCount: _allCount > 0
                    ? _allCount
                    : DispatcherNotificationsFakeData.allCount,
                unreadCount: _unreadCount,
              ),
              const SizedBox(height: Spacing.sm),
              DispatcherNotificationsSectionHeader(
                onMarkAllAsRead: _onMarkAllAsRead,
              ),
              const SizedBox(height: Spacing.xs),
              DispatcherNotificationsList(
                notifications: _filteredNotifications,
                onNotificationTap: _handleNotificationTap,
              ),
              SizedBox(
                height: widget.showBottomNavBar
                    ? Spacing.bottomNavHeight + Spacing.xl
                    : Spacing.base,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNavBar
          ? AppBottomNavBar(
              selectedIndex: _selectedBottomNavIndex,
              onItemSelected: (index) {
                if (_selectedBottomNavIndex != index) {
                  setState(() {
                    _selectedBottomNavIndex = index;
                  });
                }
              },
            )
          : null,
    );
  }
}

import '../../../../../core/network/failures.dart';
import '../../domain/entities/dispatcher_notification_entity.dart';
import '../../domain/entities/dispatcher_notification_filter_type.dart';

const _unchanged = Object();

class DispatcherNotificationsState {
  const DispatcherNotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.selectedFilter = DispatcherNotificationFilterType.all,
    this.hasLoadedOnce = false,
    this.markingReadIds = const {},
  });

  final List<DispatcherNotificationEntity> notifications;
  final bool isLoading;
  final bool isRefreshing;
  final Failure? failure;
  final DispatcherNotificationFilterType selectedFilter;
  final bool hasLoadedOnce;
  final Set<String> markingReadIds;

  int get unreadCount => notifications.where((item) => item.isUnread).length;
  int get allCount => notifications.length;
  bool get hasUnread => unreadCount > 0;

  List<DispatcherNotificationEntity> get filteredNotifications {
    switch (selectedFilter) {
      case DispatcherNotificationFilterType.all:
        return notifications.where((item) => !item.isArchived).toList();
      case DispatcherNotificationFilterType.unread:
        return notifications
            .where((item) => item.isUnread && !item.isArchived)
            .toList();
      case DispatcherNotificationFilterType.archive:
        return notifications.where((item) => item.isArchived).toList();
    }
  }

  bool get isEmpty => hasLoadedOnce && notifications.isEmpty;
  bool get isFilteredEmpty => hasLoadedOnce && filteredNotifications.isEmpty;

  DispatcherNotificationsState copyWith({
    List<DispatcherNotificationEntity>? notifications,
    bool? isLoading,
    bool? isRefreshing,
    Object? failure = _unchanged,
    DispatcherNotificationFilterType? selectedFilter,
    bool? hasLoadedOnce,
    Set<String>? markingReadIds,
  }) {
    return DispatcherNotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: identical(failure, _unchanged)
          ? this.failure
          : failure as Failure?,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      markingReadIds: markingReadIds ?? this.markingReadIds,
    );
  }
}

import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_notification_entity.dart';
import '../../domain/entities/driver_notification_filter_type.dart';

enum DriverNotificationsStateStatus {
  initial,
  loading,
  loaded,
  refreshing,
  actionLoading,
  error,
}

class DriverNotificationsState {
  const DriverNotificationsState({
    this.status = DriverNotificationsStateStatus.initial,
    this.notifications = const [],
    this.selectedFilter = DriverNotificationFilterType.all,
    this.failure,
    this.errorMessage,
  });

  final DriverNotificationsStateStatus status;
  final List<DriverNotificationEntity> notifications;
  final DriverNotificationFilterType selectedFilter;
  final Failure? failure;
  final String? errorMessage;

  bool get isLoading => status == DriverNotificationsStateStatus.loading;
  bool get isActionLoading =>
      status == DriverNotificationsStateStatus.actionLoading;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<DriverNotificationEntity> get filteredNotifications {
    if (selectedFilter == DriverNotificationFilterType.all) {
      return notifications;
    }
    return notifications
        .where((n) => n.filterCategory == selectedFilter)
        .toList();
  }

  DriverNotificationsState copyWith({
    DriverNotificationsStateStatus? status,
    List<DriverNotificationEntity>? notifications,
    DriverNotificationFilterType? selectedFilter,
    Failure? failure,
    String? errorMessage,
    bool clearFailure = false,
  }) {
    return DriverNotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      failure: clearFailure ? null : (failure ?? this.failure),
      errorMessage:
          clearFailure ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

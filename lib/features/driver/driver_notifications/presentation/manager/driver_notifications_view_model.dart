import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_notification_entity.dart';
import '../../domain/entities/driver_notification_filter_type.dart';
import '../../domain/usecase/get_driver_notifications_usecase.dart';
import '../../domain/usecase/mark_driver_notification_as_read_usecase.dart';
import 'driver_notifications_event.dart';
import 'driver_notifications_state.dart';

@injectable
class DriverNotificationsViewModel extends Cubit<DriverNotificationsState> {
  DriverNotificationsViewModel({
    required this.getNotificationsUseCase,
    required this.markAsReadUseCase,
  }) : super(const DriverNotificationsState());

  final GetDriverNotificationsUseCase getNotificationsUseCase;
  final MarkDriverNotificationAsReadUseCase markAsReadUseCase;

  void doIntent(DriverNotificationsEvent event) {
    switch (event) {
      case DriverNotificationsLoadEvent():
        _handleLoad();
      case DriverNotificationsRefreshEvent():
        _handleRefresh();
      case DriverNotificationsFilterChangedEvent(:final filter):
        _handleFilterChanged(filter);
      case DriverNotificationsMarkReadEvent(:final notificationId):
        _handleMarkRead(notificationId);
      case DriverNotificationsMarkAllReadEvent():
        _handleMarkAllRead();
    }
  }

  Future<void> _handleLoad() async {
    emit(
      state.copyWith(
        status: DriverNotificationsStateStatus.loading,
        clearFailure: true,
      ),
    );

    final result = await getNotificationsUseCase();
    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            status: DriverNotificationsStateStatus.loaded,
            notifications: data,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            status: DriverNotificationsStateStatus.error,
            failure: failure,
            errorMessage: failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _handleRefresh() async {
    emit(
      state.copyWith(
        status: DriverNotificationsStateStatus.refreshing,
        clearFailure: true,
      ),
    );

    final result = await getNotificationsUseCase();
    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            status: DriverNotificationsStateStatus.loaded,
            notifications: data,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            status: DriverNotificationsStateStatus.loaded,
            failure: failure,
            errorMessage: failure.errorMessage,
          ),
        );
    }
  }

  void _handleFilterChanged(DriverNotificationFilterType filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  Future<void> _handleMarkRead(String notificationId) async {
    final index =
        state.notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || state.notifications[index].isRead) return;

    final result = await markAsReadUseCase(notificationId);
    switch (result) {
      case ApiSuccessResult():
        final updated = List<DriverNotificationEntity>.from(state.notifications);
        updated[index] = updated[index].copyWith(isRead: true);
        emit(state.copyWith(notifications: updated));
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            failure: failure,
            errorMessage: failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _handleMarkAllRead() async {
    final unread = state.notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    emit(state.copyWith(status: DriverNotificationsStateStatus.actionLoading));

    for (final item in unread) {
      await markAsReadUseCase(item.id);
    }

    final updated = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    emit(
      state.copyWith(
        status: DriverNotificationsStateStatus.loaded,
        notifications: updated,
      ),
    );
  }
}

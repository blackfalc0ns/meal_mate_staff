import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_notification_entity.dart';
import '../../domain/entities/dispatcher_notification_filter_type.dart';
import '../../domain/usecase/get_dispatcher_notifications_usecase.dart';
import '../../domain/usecase/mark_dispatcher_notification_read_usecase.dart';
import 'dispatcher_notifications_event.dart';
import 'dispatcher_notifications_state.dart';

@injectable
class DispatcherNotificationsViewModel
    extends Cubit<DispatcherNotificationsState> {
  DispatcherNotificationsViewModel({
    required this.getNotificationsUseCase,
    required this.markReadUseCase,
  }) : super(const DispatcherNotificationsState());

  final GetDispatcherNotificationsUseCase getNotificationsUseCase;
  final MarkDispatcherNotificationReadUseCase markReadUseCase;

  Completer<void>? _inFlightLoad;

  void add(DispatcherNotificationsEvent event) => unawaited(doIntent(event));

  Future<void> doIntent(DispatcherNotificationsEvent event) async {
    switch (event) {
      case LoadDispatcherNotificationsEvent(:final isRefresh):
        await _loadNotifications(isRefresh: isRefresh);
      case MarkDispatcherNotificationReadEvent(:final notificationId):
        await _markRead(notificationId);
      case MarkAllLoadedDispatcherNotificationsReadEvent():
        await _markAllRead();
      case ChangeDispatcherNotificationsFilterEvent(:final filter):
        _changeFilter(filter);
      case ClearDispatcherNotificationsEvent():
        _clear();
    }
  }

  Future<void> _loadNotifications({bool isRefresh = false}) async {
    // In-flight coalescing to prevent duplicate concurrent network requests
    if (_inFlightLoad != null) {
      await _inFlightLoad!.future;
      return;
    }

    final completer = Completer<void>();
    _inFlightLoad = completer;

    final isInitial = !state.hasLoadedOnce && state.notifications.isEmpty && !isRefresh;
    emit(state.copyWith(
      isLoading: isInitial,
      isRefreshing: isRefresh || (!isInitial && state.hasLoadedOnce),
      failure: null,
    ));

    try {
      final result = await getNotificationsUseCase();
      switch (result) {
        case ApiSuccessResult<List<DispatcherNotificationEntity>>(:final data):
          emit(state.copyWith(
            notifications: data,
            isLoading: false,
            isRefreshing: false,
            hasLoadedOnce: true,
            failure: null,
          ));
        case ApiErrorResult<List<DispatcherNotificationEntity>>(:final failure):
          // Retain existing notifications when refresh fails
          emit(state.copyWith(
            isLoading: false,
            isRefreshing: false,
            hasLoadedOnce: true,
            failure: failure,
          ));
      }
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        hasLoadedOnce: true,
      ));
    } finally {
      if (!completer.isCompleted) completer.complete();
      _inFlightLoad = null;
    }
  }

  Future<void> _markRead(String notificationId) async {
    if (notificationId.isEmpty) return;

    final targetIndex = state.notifications.indexWhere(
      (n) => n.id == notificationId,
    );
    if (targetIndex == -1) return;

    final originalItem = state.notifications[targetIndex];
    if (!originalItem.isUnread) return; // Already read

    // Optimistic update
    final updatedList = List<DispatcherNotificationEntity>.from(state.notifications);
    updatedList[targetIndex] = originalItem.copyWith(isUnread: false);

    final markingIds = Set<String>.from(state.markingReadIds)..add(notificationId);
    emit(state.copyWith(
      notifications: updatedList,
      markingReadIds: markingIds,
    ));

    final result = await markReadUseCase(notificationId);
    final remainingIds = Set<String>.from(state.markingReadIds)..remove(notificationId);

    switch (result) {
      case ApiSuccessResult<void>():
        emit(state.copyWith(markingReadIds: remainingIds));
      case ApiErrorResult<void>(:final failure):
        // Revert optimistic update on failure to allow retry
        final revertedList = List<DispatcherNotificationEntity>.from(state.notifications);
        final currentIndex = revertedList.indexWhere((n) => n.id == notificationId);
        if (currentIndex != -1) {
          revertedList[currentIndex] = originalItem;
        }
        emit(state.copyWith(
          notifications: revertedList,
          markingReadIds: remainingIds,
          failure: failure,
        ));
    }
  }

  Future<void> _markAllRead() async {
    final unreadItems = state.notifications.where((n) => n.isUnread).toList();
    if (unreadItems.isEmpty) return;

    // Optimistically mark all loaded items as read
    final updated = state.notifications.map((n) => n.copyWith(isUnread: false)).toList();
    emit(state.copyWith(notifications: updated));

    // Best-effort batch marking loaded items
    for (final item in unreadItems) {
      unawaited(markReadUseCase(item.id));
    }
  }

  void _changeFilter(DispatcherNotificationFilterType filter) {
    if (state.selectedFilter != filter) {
      emit(state.copyWith(selectedFilter: filter));
    }
  }

  void _clear() {
    emit(const DispatcherNotificationsState());
  }
}

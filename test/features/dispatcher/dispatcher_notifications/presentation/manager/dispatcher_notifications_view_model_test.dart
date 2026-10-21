import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/domain/entities/dispatcher_notification_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/domain/entities/dispatcher_notification_filter_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/domain/repo/dispatcher_notifications_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/domain/usecase/get_dispatcher_notifications_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/domain/usecase/mark_dispatcher_notification_read_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/presentation/manager/dispatcher_notifications_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_notifications/presentation/manager/dispatcher_notifications_view_model.dart';

void main() {
  group('DispatcherNotificationsViewModel', () {
    test('initial load emits loading then populates notifications', () async {
      final repo = _FakeRepository();
      final vm = _buildViewModel(repo);

      expect(vm.state.isLoading, isFalse);
      final future = vm.doIntent(const LoadDispatcherNotificationsEvent());
      expect(vm.state.isLoading, isTrue);

      await future;

      expect(vm.state.isLoading, isFalse);
      expect(vm.state.hasLoadedOnce, isTrue);
      expect(vm.state.notifications.length, 3);
      expect(vm.state.allCount, 3);
      expect(vm.state.unreadCount, 2);
      expect(vm.state.failure, isNull);
      await vm.close();
    });

    test('in-flight coalescing prevents duplicate network calls', () async {
      final repo = _FakeRepository(delayedResponse: true);
      final vm = _buildViewModel(repo);

      // Trigger 3 simultaneous load events
      final f1 = vm.doIntent(const LoadDispatcherNotificationsEvent());
      final f2 = vm.doIntent(const LoadDispatcherNotificationsEvent());
      final f3 = vm.doIntent(const LoadDispatcherNotificationsEvent());

      repo.completePendingLoad();
      await Future.wait([f1, f2, f3]);

      expect(repo.getNotificationsCallCount, 1);
      expect(vm.state.notifications.length, 3);
      await vm.close();
    });

    test('refresh retains existing notifications on network failure', () async {
      final repo = _FakeRepository();
      final vm = _buildViewModel(repo);

      // 1. Initial success load
      await vm.doIntent(const LoadDispatcherNotificationsEvent());
      expect(vm.state.notifications.length, 3);

      // 2. Refresh fails
      repo.shouldFailLoad = true;
      final refreshFuture = vm.doIntent(
        const LoadDispatcherNotificationsEvent(isRefresh: true),
      );
      expect(vm.state.isRefreshing, isTrue);
      expect(vm.state.notifications.length, 3); // Still retained while refreshing

      await refreshFuture;
      expect(vm.state.isRefreshing, isFalse);
      // Notifications must be retained, NOT emptied! (Requirement 7)
      expect(vm.state.notifications.length, 3);
      expect(vm.state.failure, isNotNull);
      await vm.close();
    });

    test(
      'mark as read performs optimistic update and rolls back on failure',
      () async {
        final repo = _FakeRepository();
        final vm = _buildViewModel(repo);

        await vm.doIntent(const LoadDispatcherNotificationsEvent());
        expect(vm.state.notifications[0].isUnread, isTrue);
        expect(vm.state.unreadCount, 2);

        // 1. Successful mark read
        final markFuture1 = vm.doIntent(
          const MarkDispatcherNotificationReadEvent('notif-1'),
        );
        // Optimistic update immediate check
        expect(vm.state.notifications[0].isUnread, isFalse);
        expect(vm.state.unreadCount, 1);

        await markFuture1;
        expect(vm.state.notifications[0].isUnread, isFalse);
        expect(repo.markReadCallCount, 1);

        // 2. Failed mark read on item 2 -> rolls back
        repo.shouldFailMarkRead = true;
        expect(vm.state.notifications[1].isUnread, isTrue);

        final markFuture2 = vm.doIntent(
          const MarkDispatcherNotificationReadEvent('notif-2'),
        );
        expect(vm.state.notifications[1].isUnread, isFalse); // Optimistic

        await markFuture2;
        // Rolled back to true so user can retry
        expect(vm.state.notifications[1].isUnread, isTrue);
        expect(vm.state.failure, isNotNull);
        await vm.close();
      },
    );

    test('filter tabs correctly filter notifications', () async {
      final repo = _FakeRepository();
      final vm = _buildViewModel(repo);

      await vm.doIntent(const LoadDispatcherNotificationsEvent());

      // All tab
      expect(vm.state.selectedFilter, DispatcherNotificationFilterType.all);
      expect(vm.state.filteredNotifications.length, 3);

      // Switch to Unread tab
      await vm.doIntent(
        const ChangeDispatcherNotificationsFilterEvent(
          DispatcherNotificationFilterType.unread,
        ),
      );
      expect(vm.state.selectedFilter, DispatcherNotificationFilterType.unread);
      expect(vm.state.filteredNotifications.length, 2);
      expect(
        vm.state.filteredNotifications.every((n) => n.isUnread),
        isTrue,
      );

      await vm.close();
    });

    test('clear notifications on logout resets state completely', () async {
      final repo = _FakeRepository();
      final vm = _buildViewModel(repo);

      await vm.doIntent(const LoadDispatcherNotificationsEvent());
      expect(vm.state.notifications.isNotEmpty, isTrue);

      await vm.doIntent(const ClearDispatcherNotificationsEvent());
      expect(vm.state.notifications.isEmpty, isTrue);
      expect(vm.state.unreadCount, 0);
      expect(vm.state.hasLoadedOnce, isFalse);
      await vm.close();
    });
  });
}

DispatcherNotificationsViewModel _buildViewModel(_FakeRepository repo) {
  return DispatcherNotificationsViewModel(
    getNotificationsUseCase: GetDispatcherNotificationsUseCase(repo),
    markReadUseCase: MarkDispatcherNotificationReadUseCase(repo),
  );
}

class _FakeRepository implements DispatcherNotificationsRepository {
  _FakeRepository({
    this.shouldFailLoad = false,
    this.shouldFailMarkRead = false,
    this.delayedResponse = false,
  });

  bool shouldFailLoad;
  bool shouldFailMarkRead;
  bool delayedResponse;
  Completer<void>? _pendingCompleter;

  int getNotificationsCallCount = 0;
  int markReadCallCount = 0;

  void completePendingLoad() {
    _pendingCompleter?.complete();
  }

  final List<DispatcherNotificationEntity> sampleItems = [
    const DispatcherNotificationEntity(
      id: 'notif-1',
      type: DispatcherNotificationType.driverSupportIssue,
      title: 'بلاغ دعم سائق',
      description: 'وصف البلاغ',
      timeAgo: 'منذ 5 دقيقة',
      iconAsset: AppAssets.notificationIconBoxDismiss,
      isUnread: true,
      subjectId: 'issue-123',
      deepLink: '/dispatcher/support/issues/issue-123',
    ),
    const DispatcherNotificationEntity(
      id: 'notif-2',
      type: DispatcherNotificationType.driverSupportHandover,
      title: 'نقل عهدة',
      description: 'نقص في البوكس',
      timeAgo: 'منذ 10 دقيقة',
      iconAsset: AppAssets.notificationIconBox,
      isUnread: true,
      subjectId: 'handover-456',
      deepLink: '/dispatcher/support-handovers/handover-456',
    ),
    const DispatcherNotificationEntity(
      id: 'notif-3',
      type: DispatcherNotificationType.driverSupportIssueResolved,
      title: 'تم حل البلاغ',
      description: 'تم حل البلاغ بنجاح',
      timeAgo: 'منذ 1 ساعة',
      iconAsset: AppAssets.notificationIconBoxCheck,
      isUnread: false,
      subjectId: 'issue-123',
    ),
  ];

  @override
  Future<ApiResult<List<DispatcherNotificationEntity>>> getNotifications() async {
    getNotificationsCallCount++;
    if (delayedResponse) {
      _pendingCompleter = Completer<void>();
      await _pendingCompleter!.future;
    }

    if (shouldFailLoad) {
      return ApiErrorResult(
        failure: Failure(errorMessage: 'Network connection failed'),
      );
    }

    return ApiSuccessResult(data: List.from(sampleItems));
  }

  @override
  Future<ApiResult<void>> markAsRead(String notificationId) async {
    markReadCallCount++;
    if (shouldFailMarkRead) {
      return ApiErrorResult(
        failure: Failure(errorMessage: 'Server error marking read'),
      );
    }
    return const ApiSuccessResult(data: null);
  }
}

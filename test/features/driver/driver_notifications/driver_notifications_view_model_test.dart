import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/entities/driver_notification_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/entities/driver_notification_filter_type.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/entities/driver_notification_type.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/repo/driver_notifications_repository.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/usecase/get_driver_notifications_usecase.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/usecase/mark_driver_notification_as_read_usecase.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/manager/driver_notifications_event.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/manager/driver_notifications_state.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/manager/driver_notifications_view_model.dart';

class _FakeDriverNotificationsRepository
    implements DriverNotificationsRepository {
  ApiResult<List<DriverNotificationEntity>>? getNotificationsResult;
  ApiResult<void>? markAsReadResult;
  final List<String> markedReadIds = [];

  @override
  Future<ApiResult<List<DriverNotificationEntity>>> getNotifications() async {
    return getNotificationsResult ?? const ApiSuccessResult(data: []);
  }

  @override
  Future<ApiResult<void>> markAsRead(String notificationId) async {
    markedReadIds.add(notificationId);
    return markAsReadResult ?? const ApiSuccessResult(data: null);
  }
}

void main() {
  late _FakeDriverNotificationsRepository repository;
  late GetDriverNotificationsUseCase getNotificationsUseCase;
  late MarkDriverNotificationAsReadUseCase markAsReadUseCase;
  late DriverNotificationsViewModel viewModel;

  final sampleNotifications = <DriverNotificationEntity>[
    const DriverNotificationEntity(
      id: 'n1',
      type: DriverNotificationType.newOrder,
      title: 'New Order',
      body: 'New order waiting',
      time: '10:00 AM',
      isRead: false,
      filterCategory: DriverNotificationFilterType.deliveryOrders,
    ),
    const DriverNotificationEntity(
      id: 'n2',
      type: DriverNotificationType.offer,
      title: 'Offer',
      body: 'New bonus offer',
      time: '09:00 AM',
      isRead: true,
      filterCategory: DriverNotificationFilterType.offers,
    ),
    const DriverNotificationEntity(
      id: 'n3',
      type: DriverNotificationType.system,
      title: 'Maintenance',
      body: 'App maintenance scheduled',
      time: '08:00 AM',
      isRead: false,
      filterCategory: DriverNotificationFilterType.system,
    ),
  ];

  setUp(() {
    repository = _FakeDriverNotificationsRepository();
    getNotificationsUseCase = GetDriverNotificationsUseCase(repository);
    markAsReadUseCase = MarkDriverNotificationAsReadUseCase(repository);
    viewModel = DriverNotificationsViewModel(
      getNotificationsUseCase: getNotificationsUseCase,
      markAsReadUseCase: markAsReadUseCase,
    );
  });

  group('DriverNotificationsViewModel', () {
    test('initial state has correct defaults', () {
      expect(viewModel.state.status, DriverNotificationsStateStatus.initial);
      expect(viewModel.state.notifications, isEmpty);
      expect(viewModel.state.selectedFilter, DriverNotificationFilterType.all);
      expect(viewModel.state.unreadCount, 0);
    });

    test('load success populates notifications and unreadCount', () async {
      repository.getNotificationsResult =
          ApiSuccessResult<List<DriverNotificationEntity>>(
            data: sampleNotifications,
          );

      viewModel.doIntent(const DriverNotificationsLoadEvent());

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.status, DriverNotificationsStateStatus.loaded);
      expect(viewModel.state.notifications.length, 3);
      // n1 and n3 are unread -> unreadCount should be 2
      expect(viewModel.state.unreadCount, 2);
    });

    test('load failure sets error status and failure', () async {
      repository.getNotificationsResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Network timeout'),
      );

      viewModel.doIntent(const DriverNotificationsLoadEvent());

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.status, DriverNotificationsStateStatus.error);
      expect(viewModel.state.errorMessage, 'Network timeout');
      expect(viewModel.state.notifications, isEmpty);
    });

    test('refresh success updates notifications while maintaining loaded status', () async {
      repository.getNotificationsResult =
          ApiSuccessResult<List<DriverNotificationEntity>>(
            data: sampleNotifications,
          );

      viewModel.doIntent(const DriverNotificationsRefreshEvent());

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.status, DriverNotificationsStateStatus.loaded);
      expect(viewModel.state.notifications.length, 3);
    });

    test('filter change updates selectedFilter and filteredNotifications', () async {
      repository.getNotificationsResult =
          ApiSuccessResult<List<DriverNotificationEntity>>(
            data: sampleNotifications,
          );
      viewModel.doIntent(const DriverNotificationsLoadEvent());
      await Future<void>.delayed(Duration.zero);

      viewModel.doIntent(
        const DriverNotificationsFilterChangedEvent(
          DriverNotificationFilterType.offers,
        ),
      );

      expect(viewModel.state.selectedFilter, DriverNotificationFilterType.offers);
      expect(viewModel.state.filteredNotifications.length, 1);
      expect(viewModel.state.filteredNotifications.first.id, 'n2');
    });

    test('markRead updates notification to isRead: true and decreases unreadCount', () async {
      repository.getNotificationsResult =
          ApiSuccessResult<List<DriverNotificationEntity>>(
            data: sampleNotifications,
          );
      viewModel.doIntent(const DriverNotificationsLoadEvent());
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.unreadCount, 2);

      viewModel.doIntent(const DriverNotificationsMarkReadEvent('n1'));
      await Future<void>.delayed(Duration.zero);

      expect(repository.markedReadIds, contains('n1'));
      expect(viewModel.state.notifications.first.isRead, isTrue);
      expect(viewModel.state.unreadCount, 1);
    });

    test('markRead already read notification does not call repository', () async {
      repository.getNotificationsResult =
          ApiSuccessResult<List<DriverNotificationEntity>>(
            data: sampleNotifications,
          );
      viewModel.doIntent(const DriverNotificationsLoadEvent());
      await Future<void>.delayed(Duration.zero);

      // n2 is already read
      viewModel.doIntent(const DriverNotificationsMarkReadEvent('n2'));
      await Future<void>.delayed(Duration.zero);

      expect(repository.markedReadIds, isEmpty);
    });

    test('markAllRead marks all unread notifications as read and resets unreadCount', () async {
      repository.getNotificationsResult =
          ApiSuccessResult<List<DriverNotificationEntity>>(
            data: sampleNotifications,
          );
      viewModel.doIntent(const DriverNotificationsLoadEvent());
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.unreadCount, 2);

      viewModel.doIntent(const DriverNotificationsMarkAllReadEvent());
      await Future<void>.delayed(Duration.zero);

      expect(repository.markedReadIds, containsAll(['n1', 'n3']));
      expect(viewModel.state.unreadCount, 0);
      expect(viewModel.state.notifications.every((n) => n.isRead), isTrue);
      expect(viewModel.state.status, DriverNotificationsStateStatus.loaded);
    });
  });
}

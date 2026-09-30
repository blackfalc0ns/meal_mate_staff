import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/data/data_source/driver_notifications_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/data/models/driver_notification_dto.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/data/repo/driver_notifications_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/entities/driver_notification_entity.dart';

class _FakeDriverNotificationsRemoteDataSource
    implements DriverNotificationsRemoteDataSource {
  List<DriverNotificationDto>? notificationsResult;
  bool shouldThrow = false;
  DioException? dioException;

  @override
  Future<List<DriverNotificationDto>> getNotifications() async {
    if (shouldThrow) {
      throw dioException ??
          DioException(
            requestOptions: RequestOptions(path: '/api/v1/driver/notifications'),
            message: 'Server error',
          );
    }
    return notificationsResult ?? [];
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    if (shouldThrow) {
      throw dioException ??
          DioException(
            requestOptions: RequestOptions(
              path: '/api/v1/driver/notifications/$notificationId/read',
            ),
            message: 'Server error',
          );
    }
  }
}

void main() {
  late _FakeDriverNotificationsRemoteDataSource remoteDataSource;
  late DriverNotificationsRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _FakeDriverNotificationsRemoteDataSource();
    repository = DriverNotificationsRepositoryImpl(remoteDataSource);
  });

  group('DriverNotificationsRepositoryImpl', () {
    test('getNotifications returns success result with mapped entities', () async {
      remoteDataSource.notificationsResult = [
        const DriverNotificationDto(
          id: 'n1',
          type: 'new_order',
          title: 'Order #1',
          message: 'Pick up at restaurant',
          isRead: false,
        ),
        const DriverNotificationDto(
          id: 'n2',
          type: 'system',
          title: 'System update',
          message: 'Version 2 available',
          isRead: true,
        ),
      ];

      final result = await repository.getNotifications();

      expect(result, isA<ApiSuccessResult<List<DriverNotificationEntity>>>());
      final entities = (result as ApiSuccessResult<List<DriverNotificationEntity>>).data;
      expect(entities.length, 2);
      expect(entities[0].id, 'n1');
      expect(entities[0].title, 'Order #1');
      expect(entities[0].isRead, isFalse);
      expect(entities[1].id, 'n2');
      expect(entities[1].isRead, isTrue);
    });

    test('getNotifications returns error result on failure', () async {
      remoteDataSource.shouldThrow = true;

      final result = await repository.getNotifications();

      expect(result, isA<ApiErrorResult>());
    });

    test('markAsRead returns success result on 204 no content', () async {
      final result = await repository.markAsRead('notif-123');

      expect(result, isA<ApiSuccessResult>());
    });

    test('markAsRead returns error result on failure', () async {
      remoteDataSource.shouldThrow = true;

      final result = await repository.markAsRead('notif-123');

      expect(result, isA<ApiErrorResult>());
    });
  });
}

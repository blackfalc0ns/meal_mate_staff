import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/services/device_id_service.dart';
import 'package:meal_mate_delivery/core/services/local_notification_service.dart';
import 'package:meal_mate_delivery/core/services/notification_payload.dart';
import 'package:meal_mate_delivery/core/services/notification_payload_parser.dart';
import 'package:meal_mate_delivery/core/services/notification_router.dart';
import 'package:meal_mate_delivery/core/services/push_messaging_gateway.dart';
import 'package:meal_mate_delivery/core/services/push_notification_coordinator.dart';
import 'package:meal_mate_delivery/features/device_token/domain/entities/device_token_sync_context.dart';
import 'package:meal_mate_delivery/features/device_token/domain/repo/device_token_repository.dart';
import 'package:meal_mate_delivery/features/device_token/domain/usecase/deactivate_driver_device_token_usecase.dart';
import 'package:meal_mate_delivery/features/device_token/domain/usecase/deactivate_restaurant_device_token_usecase.dart';
import 'package:meal_mate_delivery/features/device_token/domain/usecase/upsert_driver_device_token_usecase.dart';
import 'package:meal_mate_delivery/features/device_token/domain/usecase/upsert_restaurant_device_token_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePushMessagingGateway implements PushMessagingGateway {
  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();
  final StreamController<PushNotificationMessage> _messageReceivedController =
      StreamController<PushNotificationMessage>.broadcast();
  final StreamController<PushNotificationMessage> _messageOpenedAppController =
      StreamController<PushNotificationMessage>.broadcast();

  String? currentToken = 'test-fcm-token';
  PushNotificationMessage? initialMessage;
  bool requestedPermission = false;

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Stream<PushNotificationMessage> get onMessageReceived =>
      _messageReceivedController.stream;

  @override
  Stream<PushNotificationMessage> get onMessageOpenedApp =>
      _messageOpenedAppController.stream;

  @override
  Future<String?> getToken() async => currentToken;

  @override
  Future<PushNotificationMessage?> getInitialMessage() async => initialMessage;

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    requestedPermission = true;
    return NotificationPermissionStatus.authorized;
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    return NotificationPermissionStatus.authorized;
  }

  void emitTokenRefresh(String token) {
    _tokenRefreshController.add(token);
  }

  void emitMessageReceived(PushNotificationMessage message) {
    _messageReceivedController.add(message);
  }

  void emitMessageOpenedApp(PushNotificationMessage message) {
    _messageOpenedAppController.add(message);
  }

  Future<void> dispose() async {
    await _tokenRefreshController.close();
    await _messageReceivedController.close();
    await _messageOpenedAppController.close();
  }
}

class FakeLocalNotificationService implements LocalNotificationService {
  final List<Map<String, dynamic>> shownNotifications = [];

  @override
  Future<void> initialize({void Function(String?)? onNotificationTap}) async {}

  @override
  Future<void> showNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {
    shownNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
    });
  }
}

class FakeDeviceIdService implements DeviceIdService {
  @override
  Future<String> getOrCreateDeviceId() async => 'test-device-id-123';
}

class FakeDeviceTokenRepository implements DeviceTokenRepository {
  List<Map<String, dynamic>> upsertDriverCalls = [];
  List<String> deactivateDriverCalls = [];
  List<Map<String, dynamic>> upsertRestaurantCalls = [];
  List<String> deactivateRestaurantCalls = [];

  ApiResult<void> upsertDriverResult = const ApiSuccessResult(data: null);
  ApiResult<void> deactivateDriverResult = const ApiSuccessResult(data: null);
  ApiResult<void> upsertRestaurantResult = const ApiSuccessResult(data: null);
  ApiResult<void> deactivateRestaurantResult = const ApiSuccessResult(
    data: null,
  );

  @override
  Future<ApiResult<void>> upsertDriverToken({
    required String token,
    required String platform,
    required String deviceId,
    String? registrationId,
  }) async {
    upsertDriverCalls.add({
      'token': token,
      'platform': platform,
      'deviceId': deviceId,
      'registrationId': registrationId,
    });
    return upsertDriverResult;
  }

  @override
  Future<ApiResult<void>> deactivateDriverToken({required String token}) async {
    deactivateDriverCalls.add(token);
    return deactivateDriverResult;
  }

  @override
  Future<ApiResult<void>> upsertRestaurantToken({
    required String token,
    required String platform,
    required String deviceId,
  }) async {
    upsertRestaurantCalls.add({
      'token': token,
      'platform': platform,
      'deviceId': deviceId,
    });
    return upsertRestaurantResult;
  }

  @override
  Future<ApiResult<void>> deactivateRestaurantToken({
    required String token,
  }) async {
    deactivateRestaurantCalls.add(token);
    return deactivateRestaurantResult;
  }
}

class FakeNotificationRouter implements NotificationRouter {
  final List<Map<String, dynamic>> routedPayloads = [];

  @override
  Duration get deduplicationWindow => const Duration(seconds: 10);

  @override
  bool isDuplicate(String key, [DateTime? now]) => false;

  @override
  Future<bool> route(
    PushNotificationPayload payload, {
    String? messageId,
  }) async {
    routedPayloads.add({'payload': payload, 'messageId': messageId});
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePushMessagingGateway gateway;
  late FakeLocalNotificationService localNotifications;
  late FakeDeviceIdService deviceIdService;
  late FakeDeviceTokenRepository repository;
  late FakeNotificationRouter router;
  late NotificationPayloadParser parser;
  late SharedPreferences sharedPreferences;
  late FlutterSecureStorage secureStorage;
  late PushNotificationCoordinator coordinator;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    sharedPreferences = await SharedPreferences.getInstance();
    secureStorage = const FlutterSecureStorage();

    gateway = FakePushMessagingGateway();
    localNotifications = FakeLocalNotificationService();
    deviceIdService = FakeDeviceIdService();
    repository = FakeDeviceTokenRepository();
    router = FakeNotificationRouter();
    parser = const NotificationPayloadParser();

    coordinator = PushNotificationCoordinator(
      gateway: gateway,
      localNotificationService: localNotifications,
      deviceIdService: deviceIdService,
      upsertDriverTokenUseCase: UpsertDriverDeviceTokenUseCase(repository),
      deactivateDriverTokenUseCase: DeactivateDriverDeviceTokenUseCase(
        repository,
      ),
      upsertRestaurantTokenUseCase: UpsertRestaurantDeviceTokenUseCase(
        repository,
      ),
      deactivateRestaurantTokenUseCase: DeactivateRestaurantDeviceTokenUseCase(
        repository,
      ),
      parser: parser,
      router: router,
      sharedPreferences: sharedPreferences,
      secureStorage: secureStorage,
    );
  });

  tearDown(() async {
    await coordinator.dispose();
    await gateway.dispose();
  });

  group('PushNotificationCoordinator initialization and lifecycle', () {
    test(
      'initialize requests permission and processes initial message',
      () async {
        gateway.initialMessage = const PushNotificationMessage(
          messageId: 'init-msg-1',
          data: {'event': 'driver.box.assigned', 'boxId': 'box-100'},
        );

        await coordinator.initialize();

        expect(gateway.requestedPermission, isTrue);
        expect(router.routedPayloads.length, 1);
        final routed = router.routedPayloads.first;
        expect(routed['payload'], isA<DriverBoxAssignedPayload>());
        expect(routed['messageId'], 'init-msg-1');
      },
    );

    test(
      'updateSyncContext for driverPreLogin calls upsert with registrationId',
      () async {
        await coordinator.initialize();

        await coordinator.updateSyncContext(
          const DeviceTokenSyncContext.driverPreLogin(
            registrationId: 'reg-abc',
          ),
        );

        expect(repository.upsertDriverCalls.length, 1);
        final call = repository.upsertDriverCalls.first;
        expect(call['token'], 'test-fcm-token');
        expect(call['deviceId'], 'test-device-id-123');
        expect(call['registrationId'], 'reg-abc');
        expect(coordinator.currentContext, isA<DriverPreLoginSyncContext>());
      },
    );

    test(
      'updateSyncContext for driverAuthenticated calls upsert without registrationId',
      () async {
        await coordinator.initialize();

        await coordinator.updateSyncContext(
          const DeviceTokenSyncContext.driverAuthenticated(userId: 'driver-1'),
        );

        expect(repository.upsertDriverCalls.length, 1);
        final call = repository.upsertDriverCalls.first;
        expect(call['token'], 'test-fcm-token');
        expect(call['registrationId'], isNull);
      },
    );

    test(
      'updateSyncContext for deliveryManagerAuthenticated calls restaurant endpoint',
      () async {
        await coordinator.initialize();

        await coordinator.updateSyncContext(
          const DeviceTokenSyncContext.deliveryManagerAuthenticated(
            userId: 'mgr-1',
          ),
        );

        expect(repository.upsertRestaurantCalls.length, 1);
        final call = repository.upsertRestaurantCalls.first;
        expect(call['token'], 'test-fcm-token');
        expect(call['deviceId'], 'test-device-id-123');
      },
    );
  });

  group('PushNotificationCoordinator retry and persistence policy', () {
    test('clears pending sync when upsert succeeds', () async {
      await sharedPreferences.setString(
        'fcm_pending_context_type',
        'driverAuthenticated',
      );
      await secureStorage.write(
        key: 'fcm_pending_replay_token',
        value: 'old-token',
      );

      repository.upsertDriverResult = const ApiSuccessResult(data: null);

      await coordinator.updateSyncContext(
        const DeviceTokenSyncContext.driverAuthenticated(userId: 'driver-1'),
      );

      expect(sharedPreferences.getString('fcm_pending_context_type'), isNull);
      expect(await secureStorage.read(key: 'fcm_pending_replay_token'), isNull);
    });

    test(
      'clears pending sync and does NOT save pending on terminal error (400, 403, 404)',
      () async {
        repository.upsertDriverResult = ApiErrorResult(
          failure: ServerFailure(
            errorMessage: 'Invalid payload',
            exception: const ApiException(
              errorType: ApiErrorType.badRequest,
              message: 'Invalid payload',
              statusCode: 400,
            ),
          ),
        );

        await coordinator.updateSyncContext(
          const DeviceTokenSyncContext.driverAuthenticated(userId: 'driver-1'),
        );

        expect(sharedPreferences.getString('fcm_pending_context_type'), isNull);
        expect(
          await secureStorage.read(key: 'fcm_pending_replay_token'),
          isNull,
        );
      },
    );

    test(
      'persists pending sync to preferences and secure storage on retryable error (500)',
      () async {
        repository.upsertDriverResult = ApiErrorResult(
          failure: ServerFailure(
            errorMessage: 'Internal Server Error',
            exception: const ApiException(
              errorType: ApiErrorType.serverError,
              message: 'Internal Server Error',
              statusCode: 500,
            ),
          ),
        );

        await coordinator.updateSyncContext(
          const DeviceTokenSyncContext.driverPreLogin(
            registrationId: 'reg-pending',
          ),
        );

        expect(
          sharedPreferences.getString('fcm_pending_context_type'),
          'driverPreLogin',
        );
        expect(
          sharedPreferences.getString('fcm_pending_registration_id'),
          'reg-pending',
        );
        expect(sharedPreferences.getInt('fcm_pending_timestamp'), isNotNull);
        expect(
          await secureStorage.read(key: 'fcm_pending_replay_token'),
          'test-fcm-token',
        );
      },
    );

    test('initialize retries persisted pending sync', () async {
      await sharedPreferences.setString(
        'fcm_pending_context_type',
        'driverPreLogin',
      );
      await sharedPreferences.setString(
        'fcm_pending_registration_id',
        'reg-retry',
      );
      await secureStorage.write(
        key: 'fcm_pending_replay_token',
        value: 'retry-token-xyz',
      );

      repository.upsertDriverResult = const ApiSuccessResult(data: null);

      await coordinator.initialize();

      expect(repository.upsertDriverCalls.length, 1);
      final call = repository.upsertDriverCalls.first;
      expect(call['token'], 'retry-token-xyz');
      expect(call['registrationId'], 'reg-retry');

      // Successful retry clears pending
      expect(sharedPreferences.getString('fcm_pending_context_type'), isNull);
      expect(await secureStorage.read(key: 'fcm_pending_replay_token'), isNull);
    });
  });

  group('PushNotificationCoordinator token refresh and deactivation', () {
    test('token refresh triggers sync when currentContext is set', () async {
      await coordinator.initialize();
      await coordinator.updateSyncContext(
        const DeviceTokenSyncContext.driverAuthenticated(userId: 'driver-1'),
      );

      expect(repository.upsertDriverCalls.length, 1);

      gateway.emitTokenRefresh('new-refreshed-token');
      await Future<void>.delayed(Duration.zero);

      expect(repository.upsertDriverCalls.length, 2);
      expect(repository.upsertDriverCalls.last['token'], 'new-refreshed-token');
    });

    test(
      'clearSyncContextAndDeactivate deactivates token and clears state',
      () async {
        await coordinator.initialize();
        await coordinator.updateSyncContext(
          const DeviceTokenSyncContext.driverAuthenticated(userId: 'driver-1'),
        );

        await coordinator.clearSyncContextAndDeactivate();

        expect(repository.deactivateDriverCalls.length, 1);
        expect(repository.deactivateDriverCalls.first, 'test-fcm-token');
        expect(coordinator.currentContext, isNull);
      },
    );

    test(
      'clearSyncContextAndDeactivate for manager calls restaurant deactivation',
      () async {
        await coordinator.initialize();
        await coordinator.updateSyncContext(
          const DeviceTokenSyncContext.deliveryManagerAuthenticated(
            userId: 'mgr-1',
          ),
        );

        await coordinator.clearSyncContextAndDeactivate();

        expect(repository.deactivateRestaurantCalls.length, 1);
        expect(repository.deactivateRestaurantCalls.first, 'test-fcm-token');
        expect(coordinator.currentContext, isNull);
      },
    );

    test(
      'clearSyncContextAndDeactivate handles deactivation failure gracefully',
      () async {
        repository.deactivateDriverResult = ApiErrorResult(
          failure: ServerFailure(
            errorMessage: 'Server down',
            exception: const ApiException(
              errorType: ApiErrorType.serverError,
              message: 'Server down',
              statusCode: 500,
            ),
          ),
        );

        await coordinator.initialize();
        await coordinator.updateSyncContext(
          const DeviceTokenSyncContext.driverAuthenticated(userId: 'driver-1'),
        );

        // Should not throw
        await expectLater(
          coordinator.clearSyncContextAndDeactivate(),
          completes,
        );
        expect(coordinator.currentContext, isNull);
      },
    );
  });

  group('PushNotificationCoordinator message handling', () {
    test(
      'foreground message shows local notification for supported event',
      () async {
        await coordinator.initialize();

        gateway.emitMessageReceived(
          const PushNotificationMessage(
            messageId: 'msg-fg-1',
            title: 'New Trip',
            body: 'You have a new trip assigned',
            data: {'event': 'driver.trip.assigned', 'tripId': 'trip-555'},
          ),
        );

        await Future<void>.delayed(Duration.zero);

        expect(localNotifications.shownNotifications.length, 1);
        final notif = localNotifications.shownNotifications.first;
        expect(notif['title'], 'New Trip');
        expect(notif['body'], 'You have a new trip assigned');
        expect(notif['payload'], contains('driver.trip.assigned'));
      },
    );

    test(
      'foreground message shows notification payload without a known event',
      () async {
        await coordinator.initialize();

        gateway.emitMessageReceived(
          const PushNotificationMessage(
            messageId: 'msg-unsupported',
            title: 'Firebase test',
            body: 'Foreground notification',
          ),
        );

        await Future<void>.delayed(Duration.zero);

        expect(localNotifications.shownNotifications, hasLength(1));
        expect(
          localNotifications.shownNotifications.single['title'],
          'Firebase test',
        );
        expect(
          localNotifications.shownNotifications.single['body'],
          'Foreground notification',
        );
      },
    );

    test('foreground message shows incoming_call event', () async {
      await coordinator.initialize();

      gateway.emitMessageReceived(
        const PushNotificationMessage(
          messageId: 'msg-call',
          title: 'Call',
          body: 'Incoming call',
          data: {'event': 'incoming_call', 'channelId': 'chan-1'},
        ),
      );

      await Future<void>.delayed(Duration.zero);

      expect(localNotifications.shownNotifications, hasLength(1));
      expect(localNotifications.shownNotifications.single['title'], 'Call');
      expect(
        localNotifications.shownNotifications.single['body'],
        'Incoming call',
      );
    });

    test('onMessageOpenedApp routes tap to NotificationRouter', () async {
      await coordinator.initialize();

      gateway.emitMessageOpenedApp(
        const PushNotificationMessage(
          messageId: 'msg-open-1',
          data: {'event': 'dispatcher.batch.ready', 'batchId': 'batch-99'},
        ),
      );

      await Future<void>.delayed(Duration.zero);

      expect(router.routedPayloads.length, 1);
      final routed = router.routedPayloads.first;
      expect(routed['payload'], isA<DispatcherBatchReadyPayload>());
      expect(routed['messageId'], 'msg-open-1');
    });

    test('handleLocalNotificationTap parses and routes json', () async {
      await coordinator.initialize();

      await coordinator.handleLocalNotificationTap(
        '{"event":"driver.box.assigned","boxId":"box-from-local"}',
      );

      expect(router.routedPayloads.length, 1);
      final routed = router.routedPayloads.first;
      expect(routed['payload'], isA<DriverBoxAssignedPayload>());
      expect(
        (routed['payload'] as DriverBoxAssignedPayload).boxId,
        'box-from-local',
      );
    });
  });
}

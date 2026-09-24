import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/device_token/domain/entities/device_token_sync_context.dart';
import '../../features/device_token/domain/usecase/deactivate_driver_device_token_usecase.dart';
import '../../features/device_token/domain/usecase/deactivate_restaurant_device_token_usecase.dart';
import '../../features/device_token/domain/usecase/upsert_driver_device_token_usecase.dart';
import '../../features/device_token/domain/usecase/upsert_restaurant_device_token_usecase.dart';
import '../network/api_results.dart';
import '../network/failures.dart';
import 'device_id_service.dart';
import 'local_notification_service.dart';
import 'notification_payload.dart';
import 'notification_payload_parser.dart';
import 'notification_router.dart';
import 'push_messaging_gateway.dart';

class PushNotificationCoordinator {
  PushNotificationCoordinator({
    required this.gateway,
    required this.localNotificationService,
    required this.deviceIdService,
    required this.upsertDriverTokenUseCase,
    required this.deactivateDriverTokenUseCase,
    required this.upsertRestaurantTokenUseCase,
    required this.deactivateRestaurantTokenUseCase,
    required this.parser,
    required this.router,
    required this.sharedPreferences,
    required this.secureStorage,
  });

  static const String _prefPendingContextType = 'fcm_pending_context_type';
  static const String _prefPendingRegistrationId =
      'fcm_pending_registration_id';
  static const String _prefPendingTimestamp = 'fcm_pending_timestamp';
  static const String _securePendingTokenKey = 'fcm_pending_replay_token';

  final PushMessagingGateway gateway;
  final LocalNotificationService localNotificationService;
  final DeviceIdService deviceIdService;
  final UpsertDriverDeviceTokenUseCase upsertDriverTokenUseCase;
  final DeactivateDriverDeviceTokenUseCase deactivateDriverTokenUseCase;
  final UpsertRestaurantDeviceTokenUseCase upsertRestaurantTokenUseCase;
  final DeactivateRestaurantDeviceTokenUseCase deactivateRestaurantTokenUseCase;
  final NotificationPayloadParser parser;
  final NotificationRouter router;
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  bool _isInitialized = false;
  DeviceTokenSyncContext? _currentContext;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<PushNotificationMessage>? _foregroundSub;
  StreamSubscription<PushNotificationMessage>? _messageOpenedSub;
  Completer<void>? _inFlightSync;

  DeviceTokenSyncContext? get currentContext => _currentContext;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      await gateway.requestPermission();
    } catch (_) {}

    _tokenRefreshSub = gateway.onTokenRefresh.listen((token) {
      unawaited(_handleTokenRefresh(token));
    });

    _foregroundSub = gateway.onMessageReceived.listen((message) {
      unawaited(_handleForegroundMessage(message));
    });

    _messageOpenedSub = gateway.onMessageOpenedApp.listen((message) {
      unawaited(_handleMessageTap(message));
    });

    try {
      final initialMessage = await gateway.getInitialMessage();
      if (initialMessage != null) {
        await _handleMessageTap(initialMessage);
      }
    } catch (_) {}

    await _retryPendingSync();
  }

  Future<void> updateSyncContext(DeviceTokenSyncContext context) async {
    _currentContext = context;
    await _syncTokenForContext(context);
  }

  Future<void> clearSyncContextAndDeactivate() async {
    final context = _currentContext;
    _currentContext = null;
    await _clearPendingSync();

    if (context == null) return;

    try {
      final token = await gateway.getToken();
      if (token == null || token.trim().isEmpty) return;

      switch (context) {
        case DriverPreLoginSyncContext():
        case DriverAuthenticatedSyncContext():
          await deactivateDriverTokenUseCase(token: token);
        case DeliveryManagerAuthenticatedSyncContext():
          await deactivateRestaurantTokenUseCase(token: token);
      }
    } catch (_) {
      // Best-effort deactivation, never fail logout
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _messageOpenedSub?.cancel();
    _isInitialized = false;
  }

  Future<void> _syncTokenForContext(
    DeviceTokenSyncContext context, {
    String? explicitToken,
  }) async {
    if (_inFlightSync != null) {
      await _inFlightSync!.future;
    }

    final completer = Completer<void>();
    _inFlightSync = completer;

    try {
      final token = explicitToken ?? await gateway.getToken();
      if (token == null || token.trim().isEmpty) {
        completer.complete();
        _inFlightSync = null;
        return;
      }

      final deviceId = await deviceIdService.getOrCreateDeviceId();
      final platform = _resolvePlatform();

      ApiResult<void> result;
      switch (context) {
        case DriverPreLoginSyncContext(:final registrationId):
          result = await upsertDriverTokenUseCase(
            token: token,
            platform: platform,
            deviceId: deviceId,
            registrationId: registrationId,
          );

        case DriverAuthenticatedSyncContext():
          result = await upsertDriverTokenUseCase(
            token: token,
            platform: platform,
            deviceId: deviceId,
          );

        case DeliveryManagerAuthenticatedSyncContext():
          result = await upsertRestaurantTokenUseCase(
            token: token,
            platform: platform,
            deviceId: deviceId,
          );
      }

      switch (result) {
        case ApiSuccessResult():
          await _clearPendingSync();

        case ApiErrorResult(:final failure):
          if (_isTerminalError(failure)) {
            await _clearPendingSync();
          } else {
            await _persistPendingSync(context, token);
          }
      }
    } catch (_) {
      // Guard against unexpected platform exceptions
    } finally {
      if (!completer.isCompleted) completer.complete();
      _inFlightSync = null;
    }
  }

  Future<void> _handleTokenRefresh(String token) async {
    if (_currentContext != null) {
      await _syncTokenForContext(_currentContext!, explicitToken: token);
    }
  }

  Future<void> _handleForegroundMessage(PushNotificationMessage message) async {
    final payload = parser.parse(message.data);
    if (payload is UnsupportedNotificationPayload ||
        payload is IncomingCallPayload) {
      return;
    }

    final title = message.title ?? 'MealMate';
    final body = message.body ?? '';
    final encodedData = jsonEncode(message.data);

    await localNotificationService.showNotification(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      payload: encodedData,
    );
  }

  Future<void> _handleMessageTap(PushNotificationMessage message) async {
    final payload = parser.parse(message.data);
    await router.route(payload, messageId: message.messageId);
  }

  Future<void> handleLocalNotificationTap(String? rawJson) async {
    if (rawJson == null || rawJson.trim().isEmpty) return;
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        final payload = parser.parse(decoded);
        await router.route(payload);
      }
    } catch (_) {}
  }

  String _resolvePlatform() {
    if (!kIsWeb && Platform.isIOS) {
      return 'iOS';
    }
    return 'Android';
  }

  bool _isTerminalError(Failure failure) {
    final code = failure.exception.statusCode;
    if (code == 400 || code == 403 || code == 404) {
      return true;
    }
    return false;
  }

  Future<void> _persistPendingSync(
    DeviceTokenSyncContext context,
    String token,
  ) async {
    final contextType = switch (context) {
      DriverPreLoginSyncContext() => 'driverPreLogin',
      DriverAuthenticatedSyncContext() => 'driverAuthenticated',
      DeliveryManagerAuthenticatedSyncContext() =>
        'deliveryManagerAuthenticated',
    };

    await sharedPreferences.setString(_prefPendingContextType, contextType);
    if (context is DriverPreLoginSyncContext) {
      await sharedPreferences.setString(
        _prefPendingRegistrationId,
        context.registrationId,
      );
    } else {
      await sharedPreferences.remove(_prefPendingRegistrationId);
    }
    await sharedPreferences.setInt(
      _prefPendingTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
    await secureStorage.write(key: _securePendingTokenKey, value: token);
  }

  Future<void> _clearPendingSync() async {
    await sharedPreferences.remove(_prefPendingContextType);
    await sharedPreferences.remove(_prefPendingRegistrationId);
    await sharedPreferences.remove(_prefPendingTimestamp);
    await secureStorage.delete(key: _securePendingTokenKey);
  }

  Future<void> _retryPendingSync() async {
    final contextType = sharedPreferences.getString(_prefPendingContextType);
    if (contextType == null) return;

    final token = await secureStorage.read(key: _securePendingTokenKey);
    if (token == null || token.trim().isEmpty) {
      await _clearPendingSync();
      return;
    }

    DeviceTokenSyncContext? pendingContext;
    if (contextType == 'driverPreLogin') {
      final regId = sharedPreferences.getString(_prefPendingRegistrationId);
      if (regId != null && regId.isNotEmpty) {
        pendingContext = DeviceTokenSyncContext.driverPreLogin(
          registrationId: regId,
        );
      }
    } else if (contextType == 'driverAuthenticated') {
      pendingContext = const DeviceTokenSyncContext.driverAuthenticated(
        userId: '',
      );
    } else if (contextType == 'deliveryManagerAuthenticated') {
      pendingContext =
          const DeviceTokenSyncContext.deliveryManagerAuthenticated(userId: '');
    }

    if (pendingContext != null) {
      await _syncTokenForContext(pendingContext, explicitToken: token);
    }
  }
}

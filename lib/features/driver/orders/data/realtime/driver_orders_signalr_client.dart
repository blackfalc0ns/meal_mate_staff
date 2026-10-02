import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../../../../core/network/network_constants.dart';
import '../../../../../core/services/auth_refresh_service.dart';
import '../../../../../core/services/token_service.dart';
import '../../domain/entities/driver_orders_realtime_event.dart';
import '../models/realtime/driver_orders_realtime_event_dto.dart';
import 'driver_orders_realtime_client.dart';

@LazySingleton(as: DriverOrdersRealtimeClient)
class DriverOrdersSignalRClient implements DriverOrdersRealtimeClient {
  DriverOrdersSignalRClient(
    this._tokenService, {
    this.refreshService,
    String? hubUrl,
    HubConnection? hubConnection,
  }) : _customHubUrl = hubUrl,
       _providedHubConnection = hubConnection;

  final TokenService _tokenService;
  final AuthRefreshService? refreshService;
  final String? _customHubUrl;
  final HubConnection? _providedHubConnection;

  HubConnection? _hubConnection;
  Future<void>? _inFlightStart;
  bool _isDisposed = false;
  bool _handlersRegistered = false;
  bool _isConnected = false;
  String? _builtWithToken;

  final _eventController =
      StreamController<DriverOrdersRealtimeEvent>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  // Bounded deduplication set (up to 200 recent event IDs)
  final Queue<String> _recentEventIdQueue = Queue<String>();
  final Set<String> _recentEventIdSet = <String>{};
  static const int _maxDeduplicationSize = 200;

  static const List<String> supportedEvents = [
    'box-delivered',
    'delivery-failed',
    'driver-arrived-at-customer',
    'driver-requested-reassignment',
    'trip-in-transit',
    'box-assigned',
    'box-reassigned',
    'delivery-completed',
    'kitchen-ready',
    'shift-status-confirmed',
    'dispatcher-message',
    'connection-established',
  ];

  @override
  Stream<DriverOrdersRealtimeEvent> get events => _eventController.stream;

  @override
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  @override
  bool get isConnected =>
      !_isDisposed &&
      _isConnected &&
      _hubConnection?.state == HubConnectionState.Connected;

  static String buildHubUrl({String? base}) {
    final raw = base ?? NetworkConstants.baseUrl;
    final uri = Uri.parse(raw);
    final targetPath = EndPoints.driverHub.startsWith('/')
        ? EndPoints.driverHub.substring(1)
        : EndPoints.driverHub;
    final normalizedPath = uri.path.endsWith('/')
        ? '${uri.path}$targetPath'
        : uri.path.isEmpty || uri.path == '/'
        ? '/$targetPath'
        : '${uri.path}/$targetPath';
    return uri.replace(path: normalizedPath).toString();
  }

  String get _resolvedHubUrl => _customHubUrl ?? buildHubUrl();

  void _log(String message, {Object? error}) {
    developer.log(message, name: 'DriverOrdersSignalR', error: error);
  }

  void _emitConnectionStatus(bool connected) {
    if (_isDisposed || _isConnected == connected) return;
    _isConnected = connected;
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(connected);
    }
  }

  void _ensureHubBuilt(String token) {
    if (_hubConnection != null && _builtWithToken == token) return;

    if (_hubConnection != null && _builtWithToken != token) {
      _removeHandlers();
      try {
        unawaited(_hubConnection?.stop());
      } catch (_) {}
      _hubConnection = null;
    }

    _builtWithToken = token;

    if (_providedHubConnection != null) {
      _hubConnection = _providedHubConnection;
    } else {
      final uri = Uri.parse(_resolvedHubUrl);
      final queryParams = Map<String, String>.from(uri.queryParameters);
      queryParams['access_token'] = token;
      final fullUrl = uri.replace(queryParameters: queryParams).toString();

      final httpOptions = HttpConnectionOptions(
        accessTokenFactory: () async => token,
      );

      _hubConnection = HubConnectionBuilder()
          .withUrl(fullUrl, options: httpOptions)
          .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 10000])
          .build();
    }

    _registerLifecycleCallbacks();
    _registerEventHandlers();
  }

  void _registerLifecycleCallbacks() {
    final hub = _hubConnection;
    if (hub == null) return;

    hub.onclose(({Exception? error}) {
      if (_isDisposed) return;
      _log('📶 Hub onclose: $error');
      _emitConnectionStatus(false);
    });

    hub.onreconnecting(({Exception? error}) {
      if (_isDisposed) return;
      _log('🔄 Hub onreconnecting: $error');
      _emitConnectionStatus(false);
    });

    hub.onreconnected(({String? connectionId}) {
      if (_isDisposed) return;
      _log('✅ Hub onreconnected with ID: $connectionId');
      _emitConnectionStatus(true);
      if (!_eventController.isClosed) {
        _eventController.add(
          DriverConnectionEstablishedEvent(
            eventId: 'conn-${DateTime.now().millisecondsSinceEpoch}',
            occurredAtUtc: DateTime.now().toUtc(),
            connectionId: connectionId,
          ),
        );
      }
    });
  }

  void _registerEventHandlers() {
    final hub = _hubConnection;
    if (hub == null || _handlersRegistered) return;
    _handlersRegistered = true;

    for (final eventName in supportedEvents) {
      hub.on(eventName, (List<Object?>? args) {
        if (_isDisposed || args == null || args.isEmpty) return;
        _handleIncomingEvent(eventName, args.first);
      });
    }
  }

  void _handleIncomingEvent(String eventName, Object? rawPayload) {
    try {
      if (rawPayload is! Map) return;

      final map = Map<String, dynamic>.from(rawPayload);
      final eventId = (map['eventId'] ?? '').toString();

      if (eventId.isNotEmpty) {
        if (_recentEventIdSet.contains(eventId)) {
          _log('Duplicate event received and skipped: $eventId');
          return;
        }

        _recentEventIdSet.add(eventId);
        _recentEventIdQueue.addLast(eventId);
        if (_recentEventIdQueue.length > _maxDeduplicationSize) {
          final removed = _recentEventIdQueue.removeFirst();
          _recentEventIdSet.remove(removed);
        }
      }

      final domainEvent = DriverOrdersRealtimeEventDto.fromPayload(
        eventName,
        map,
      );

      if (!_eventController.isClosed) {
        _eventController.add(domainEvent);
      }
    } catch (e) {
      _log('Error processing realtime event $eventName: $e', error: e);
    }
  }

  void _removeHandlers() {
    final hub = _hubConnection;
    if (hub == null || !_handlersRegistered) return;

    for (final eventName in supportedEvents) {
      try {
        hub.off(eventName);
      } catch (_) {}
    }
    _handlersRegistered = false;
  }

  @override
  Future<void> start() async {
    if (_isDisposed) return;
    if (_isConnected && _hubConnection?.state == HubConnectionState.Connected) {
      return;
    }
    if (_inFlightStart != null) return _inFlightStart!;

    _inFlightStart = _doStart();
    try {
      await _inFlightStart;
    } finally {
      _inFlightStart = null;
    }
  }

  Future<void> _doStart() async {
    try {
      final token = await _tokenService.getToken();
      if (token == null || token.isEmpty) {
        _log('Cannot connect to SignalR: missing auth token');
        return;
      }

      _ensureHubBuilt(token);
      await _hubConnection?.start();
      _emitConnectionStatus(true);
      _log('🚀 SignalR Driver Hub connection started successfully');
    } catch (e) {
      _log('Failed to start SignalR connection: $e', error: e);
      _emitConnectionStatus(false);
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('unauthorized')) {
        await _handleTokenExpired();
      }
    }
  }

  Future<void> _handleTokenExpired() async {
    if (refreshService == null) return;
    try {
      _log('Refreshing expired token for Driver Hub...');
      final newToken = await refreshService!.refreshToken();
      if (newToken != null && newToken.isNotEmpty) {
        _ensureHubBuilt(newToken);
        await _hubConnection?.start();
        _emitConnectionStatus(true);
      }
    } catch (refreshErr) {
      _log('Failed to refresh token for Driver Hub: $refreshErr', error: refreshErr);
    }
  }

  @override
  Future<Map<String, dynamic>?> updateLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
  }) async {
    if (_isDisposed) {
      throw StateError('SignalR client is disposed');
    }

    // Client-side validation: coordinates must be valid and not 0,0
    if (latitude == 0 && longitude == 0) {
      _log('⚠️ Coordinates (0,0) rejected by client validation');
      throw ArgumentError('Invalid zero coordinates');
    }

    if (!isConnected) {
      await start();
      if (!isConnected) {
        throw StateError('Driver hub is not connected');
      }
    }

    try {
      final args = <Object>[
        latitude,
        longitude,
        heading ?? 0.0,
        speedKmh ?? 0.0,
      ];
      final result = await _hubConnection!.invoke(
        'UpdateLocation',
        args: args,
      );

      if (result is Map) {
        final ack = Map<String, dynamic>.from(result);
        _log(
          '📍 [ACK] Location update confirmed: id=${ack['trackingPointId']}, '
          'remaining=${ack['remainingDistanceKm']}km',
        );
        return ack;
      }
      return null;
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      _log('❌ [HubException] UpdateLocation failed: $e');

      if (errStr.contains('dispatcher.tracking_not_required') ||
          errStr.contains('tracking_not_required')) {
        _log('🛑 Received dispatcher.tracking_not_required. Halting stream!');
        if (!_eventController.isClosed) {
          _eventController.add(
            DriverTrackingNotRequiredEvent(
              eventId: 'tracking-not-required-${DateTime.now().millisecondsSinceEpoch}',
              occurredAtUtc: DateTime.now().toUtc(),
              reason: 'dispatcher.tracking_not_required',
            ),
          );
        }
      } else if (errStr.contains('unauthorized')) {
        await _handleTokenExpired();
      }

      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    _removeHandlers();
    try {
      await _hubConnection?.stop();
    } catch (_) {}
    _emitConnectionStatus(false);
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    await stop();
    await _eventController.close();
    await _connectionStatusController.close();
  }
}

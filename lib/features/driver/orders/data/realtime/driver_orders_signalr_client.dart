import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../../../../core/network/network_constants.dart';
import '../../../../../core/services/token_service.dart';
import '../../domain/entities/driver_orders_realtime_event.dart';
import '../models/realtime/driver_orders_realtime_event_dto.dart';
import 'driver_orders_realtime_client.dart';

@LazySingleton(as: DriverOrdersRealtimeClient)
class DriverOrdersSignalRClient implements DriverOrdersRealtimeClient {
  DriverOrdersSignalRClient(
    this._tokenService, {
    String? hubUrl,
    HubConnection? hubConnection,
  }) : _customHubUrl = hubUrl,
       _providedHubConnection = hubConnection;

  final TokenService _tokenService;
  final String? _customHubUrl;
  final HubConnection? _providedHubConnection;

  HubConnection? _hubConnection;
  Future<void>? _inFlightStart;
  bool _isDisposed = false;
  bool _handlersRegistered = false;
  bool _isConnected = false;

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
  ];

  @override
  Stream<DriverOrdersRealtimeEvent> get events => _eventController.stream;

  @override
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  static String buildHubUrl({String? base}) {
    final raw = base ?? NetworkConstants.baseUrl;
    final uri = Uri.parse(raw);
    final normalizedPath = uri.path.endsWith('/')
        ? '${uri.path}hubs/driver'
        : uri.path.isEmpty || uri.path == '/'
        ? '/hubs/driver'
        : '${uri.path}/hubs/driver';
    return uri.replace(path: normalizedPath).toString();
  }

  String get _resolvedHubUrl => _customHubUrl ?? buildHubUrl();

  void _log(String message) {
    developer.log(message, name: 'DriverOrdersSignalR');
  }

  void _emitConnectionStatus(bool connected) {
    if (_isDisposed || _isConnected == connected) return;
    _isConnected = connected;
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(connected);
    }
  }

  void _ensureHubBuilt(String token) {
    if (_hubConnection != null) return;

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
          .withAutomaticReconnect(retryDelays: [2000, 5000, 10000, 30000])
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
      _emitConnectionStatus(false);
    });

    hub.onreconnecting(({Exception? error}) {
      if (_isDisposed) return;
      _emitConnectionStatus(false);
    });

    hub.onreconnected(({String? connectionId}) {
      if (_isDisposed) return;
      _emitConnectionStatus(true);
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
      _log('Error processing realtime event $eventName: $e');
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
    if (_isConnected) return;
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
    } catch (e) {
      _log('Failed to start SignalR connection: $e');
      _emitConnectionStatus(false);
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

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:signalr_netcore/signalr_client.dart';

import '../../../../../core/network/network_constants.dart';
import '../../../../../core/services/auth_refresh_service.dart';
import '../../../../../core/services/token_service.dart';
import '../../domain/entities/dispatcher_map_connection_status.dart';
import '../models/realtime/dispatcher_box_assigned_event_dto.dart';
import '../models/realtime/dispatcher_driver_issue_event_dto.dart';
import '../models/realtime/dispatcher_driver_location_event_dto.dart';
import '../models/realtime/dispatcher_driver_status_event_dto.dart';
import 'dispatcher_map_realtime_client.dart';
import 'dispatcher_map_realtime_event_dto.dart';

class DispatcherMapSignalRClient implements DispatcherMapRealtimeClient {
  DispatcherMapSignalRClient(
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
  Future<void>? _inFlightConnect;
  bool _isDisposed = false;
  bool _handlersRegistered = false;

  final _eventController =
      StreamController<DispatcherMapRealtimeEventDto>.broadcast();
  final _connectionStatusController =
      StreamController<DispatcherMapConnectionStatus>.broadcast();

  DispatcherMapConnectionStatus _currentStatus =
      DispatcherMapConnectionStatus.disconnected;

  @override
  Stream<DispatcherMapRealtimeEventDto> get events => _eventController.stream;

  @override
  Stream<DispatcherMapConnectionStatus> get connectionStatuses =>
      _connectionStatusController.stream;

  DispatcherMapConnectionStatus get currentStatus => _currentStatus;

  static String buildHubUrl({String? base}) {
    final raw = base ?? NetworkConstants.baseUrl;
    final uri = Uri.parse(raw);
    final normalizedPath = uri.path.endsWith('/')
        ? '${uri.path}hubs/dispatcher'
        : uri.path.isEmpty || uri.path == '/'
        ? '/hubs/dispatcher'
        : '${uri.path}/hubs/dispatcher';
    return uri.replace(path: normalizedPath).toString();
  }

  String get _resolvedHubUrl => _customHubUrl ?? buildHubUrl();

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'DispatcherSignalR',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _emitStatus(DispatcherMapConnectionStatus status) {
    if (_isDisposed || _currentStatus == status) return;
    _currentStatus = status;
    _log('📶 [STATUS] Connection status changed to: ${status.name}');
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(status);
    }
  }

  String? _builtWithToken;

  void _ensureHubBuilt(String token) {
    if (_hubConnection != null && _builtWithToken == token) return;

    if (_hubConnection != null && _builtWithToken != token) {
      _removeHandlers();
      try {
        _hubConnection?.stop();
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

      _log('🔧 [INIT] Building HubConnection with URL: $fullUrl');
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

  void _debugToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final normalized = base64Url.normalize(parts[1]);
        final payload = utf8.decode(base64Url.decode(normalized));
        final data = jsonDecode(payload) as Map<String, dynamic>;

        final exp = data['exp'];
        String expInfo = 'none';
        if (exp is num) {
          final expDate = DateTime.fromMillisecondsSinceEpoch(
            exp.toInt() * 1000,
          );
          final isExpired = DateTime.now().isAfter(expDate);
          expInfo = '$expDate (IsExpired: $isExpired)';
        }

        final role =
            data['role'] ??
            data['roles'] ??
            data['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
        final restaurant = data['mm_restaurant_id'] ?? data['restaurant_id'];

        _log(
          '🔍 [TOKEN] Exp: $expInfo | Role: $role | Restaurant: $restaurant',
        );
      } else {
        _log(
          '🔍 [TOKEN] Non-JWT token format detected (length: ${token.length})',
        );
      }
    } catch (e) {
      _log('🔍 [TOKEN] Could not decode token claims: $e');
    }
  }

  void _registerLifecycleCallbacks() {
    final hub = _hubConnection;
    if (hub == null) return;

    hub.onclose(({Exception? error}) {
      if (_isDisposed) return;
      _log(
        '🔌 [LIFECYCLE] onclose triggered: ${error ?? "Normal closure"}',
        error: error,
      );
      _emitStatus(DispatcherMapConnectionStatus.disconnected);
    });

    hub.onreconnecting(({Exception? error}) {
      if (_isDisposed) return;
      _log(
        '🔄 [LIFECYCLE] onreconnecting triggered: ${error ?? "Reconnecting..."}',
        error: error,
      );
      _emitStatus(DispatcherMapConnectionStatus.reconnecting);
    });

    hub.onreconnected(({String? connectionId}) {
      if (_isDisposed) return;
      _log(
        '✅ [LIFECYCLE] onreconnected successfully! connectionId: $connectionId',
      );
      _emitStatus(DispatcherMapConnectionStatus.connected);
    });
  }

  void _registerEventHandlers() {
    final hub = _hubConnection;
    if (hub == null || _handlersRegistered) return;
    _handlersRegistered = true;

    hub.on('driver-location-updated', (List<Object?>? args) {
      if (_isDisposed || args == null || args.isEmpty) return;
      try {
        final map = _toMap(args.first);
        final dto = DispatcherDriverLocationEventDto.fromJson(map);
        if (dto.driverId != null &&
            dto.latitude != null &&
            dto.longitude != null) {
          _log(
            '📍 [REALTIME] Driver location updated: driverId=${dto.driverId}, lat=${dto.latitude}, lng=${dto.longitude}',
          );
          if (!_eventController.isClosed) {
            _eventController.add(LocationUpdatedRealtimeDto(dto));
          }
        }
      } catch (e) {
        _log(
          '⚠️ [REALTIME] Error parsing driver-location-updated: $e',
          error: e,
        );
      }
    });

    hub.on('driver-status-updated', (List<Object?>? args) {
      if (_isDisposed || args == null || args.isEmpty) return;
      try {
        final map = _toMap(args.first);
        final dto = DispatcherDriverStatusEventDto.fromJson(map);
        if (dto.driverId != null) {
          _log(
            '📊 [REALTIME] Driver status updated: driverId=${dto.driverId}, status=${dto.status}',
          );
          if (!_eventController.isClosed) {
            _eventController.add(StatusUpdatedRealtimeDto(dto));
          }
        }
      } catch (e) {
        _log('⚠️ [REALTIME] Error parsing driver-status-updated: $e', error: e);
      }
    });

    hub.on('driver-issue-updated', (List<Object?>? args) {
      if (_isDisposed || args == null || args.isEmpty) return;
      try {
        final map = _toMap(args.first);
        final dto = DispatcherDriverIssueEventDto.fromJson(map);
        if (dto.driverId != null) {
          _log(
            '🚨 [REALTIME] Driver issue updated: driverId=${dto.driverId}, hasIssue=${dto.hasIssue}',
          );
          if (!_eventController.isClosed) {
            _eventController.add(IssueUpdatedRealtimeDto(dto));
          }
        }
      } catch (e) {
        _log('⚠️ [REALTIME] Error parsing driver-issue-updated: $e', error: e);
      }
    });

    hub.on('box-assigned', (List<Object?>? args) {
      if (_isDisposed || args == null || args.isEmpty) return;
      try {
        final map = _toMap(args.first);
        final dto = DispatcherBoxAssignedEventDto.fromJson(map);
        _log(
          '📦 [REALTIME] Box assigned: boxId=${dto.boxId}, driverId=${dto.driverId}',
        );
        if (!_eventController.isClosed) {
          _eventController.add(BoxAssignedRealtimeDto(dto));
        }
      } catch (e) {
        _log('⚠️ [REALTIME] Error parsing box-assigned: $e', error: e);
      }
    });
  }

  void _removeHandlers() {
    final hub = _hubConnection;
    if (hub == null) return;
    hub.off('driver-location-updated');
    hub.off('driver-status-updated');
    hub.off('driver-issue-updated');
    hub.off('box-assigned');
    _handlersRegistered = false;
  }

  Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return const {};
  }

  static const int _maxConnectRetries = 3;
  static const List<Duration> _retryDelays = [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
  ];
  int _retryAttempt = 0;
  Timer? _retryTimer;
  final Set<String> _owners = <String>{};

  @override
  Future<void> acquire(String ownerId) {
    if (_isDisposed) return Future.value();
    _owners.add(ownerId);
    _log('👥 [OWNER] Owner acquired: $ownerId (total owners: ${_owners.length})');
    return connect();
  }

  @override
  Future<void> release(String ownerId) {
    if (_isDisposed) return Future.value();
    _owners.remove(ownerId);
    _log('👥 [OWNER] Owner released: $ownerId (remaining owners: ${_owners.length})');
    if (_owners.isEmpty) {
      return disconnect();
    }
    return Future.value();
  }

  @override
  Future<void> connect() {
    if (_isDisposed ||
        _currentStatus == DispatcherMapConnectionStatus.connected ||
        _currentStatus == DispatcherMapConnectionStatus.connecting) {
      return Future.value();
    }

    _retryTimer?.cancel();
    _retryTimer = null;

    if (_inFlightConnect != null) {
      return _inFlightConnect!;
    }

    _inFlightConnect = _doConnect().whenComplete(() {
      _inFlightConnect = null;
    });

    return _inFlightConnect!;
  }

  Future<void> _doConnect() async {
    final token = await _tokenService.getToken();
    if (token == null || token.isEmpty) {
      _log('⚠️ [AUTH] Cannot connect: Bearer token is missing or empty.');
      _emitStatus(DispatcherMapConnectionStatus.unauthorized);
      return;
    }

    _debugToken(token);
    _ensureHubBuilt(token);

    _log('⏳ [CONNECTING] Connecting to SignalR Hub: $_resolvedHubUrl');
    _emitStatus(DispatcherMapConnectionStatus.connecting);

    try {
      await _hubConnection?.start();
      _retryAttempt = 0;
      _log(
        '🚀 [SUCCESS] SignalR connected successfully! Real-time stream active.',
      );
      _emitStatus(DispatcherMapConnectionStatus.connected);
    } catch (e, stack) {
      final errorString = e.toString().toLowerCase();
      _log(
        '❌ [FAILED] SignalR connection attempt failed: $e',
        error: e,
        stackTrace: stack,
      );
      if (errorString.contains('401') || errorString.contains('403')) {
        if (refreshService != null) {
          _log(
            '🔄 [AUTH] Received 401/403. Attempting token refresh via AuthRefreshService...',
          );
          final refreshedToken = await refreshService!.refreshToken();
          if (refreshedToken != null && refreshedToken.isNotEmpty) {
            _log(
              '🔑 [AUTH] New token acquired. Retrying connection with fresh token...',
            );
            _debugToken(refreshedToken);
            _ensureHubBuilt(refreshedToken);
            try {
              await _hubConnection?.start();
              _retryAttempt = 0;
              _log(
                '🚀 [SUCCESS] SignalR connected successfully with refreshed token!',
              );
              _emitStatus(DispatcherMapConnectionStatus.connected);
              return;
            } catch (retryError, retryStack) {
              _log(
                '❌ [FAILED] Retry with refreshed token failed: $retryError',
                error: retryError,
                stackTrace: retryStack,
              );
            }
          } else {
            _log('⚠️ [AUTH] Token refresh returned null or empty.');
          }
        }
        _retryAttempt = 0;
        _log(
          '⛔ [UNAUTHORIZED] Server rejected connection with 401/403 Unauthorized.',
        );
        _emitStatus(DispatcherMapConnectionStatus.unauthorized);
      } else {
        _handleConnectFailure();
      }
    }
  }

  void _handleConnectFailure() {
    if (_isDisposed) return;

    if (_retryAttempt < _maxConnectRetries) {
      final delay = _retryDelays[_retryAttempt];
      _retryAttempt++;
      _log(
        '🔁 [RETRY] Scheduling reconnect attempt $_retryAttempt/$_maxConnectRetries in ${delay.inSeconds}s...',
      );
      _emitStatus(DispatcherMapConnectionStatus.reconnecting);
      _retryTimer?.cancel();
      _retryTimer = Timer(delay, () {
        if (!_isDisposed &&
            _currentStatus != DispatcherMapConnectionStatus.connected) {
          _log('⏰ [RETRY] Executing reconnect attempt $_retryAttempt...');
          connect();
        }
      });
    } else {
      _log(
        '🛑 [STOPPED] Max reconnect attempts ($_maxConnectRetries) reached. Marked as disconnected.',
      );
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryAttempt = 0;
      _emitStatus(DispatcherMapConnectionStatus.disconnected);
    }
  }

  @override
  Future<void> disconnect() async {
    _log('⏹️ [DISCONNECT] disconnect() called.');
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;

    if (_isDisposed ||
        _currentStatus == DispatcherMapConnectionStatus.disconnected ||
        _hubConnection == null) {
      _emitStatus(DispatcherMapConnectionStatus.disconnected);
      return;
    }

    try {
      await _hubConnection?.stop();
      _log('⏹️ [DISCONNECT] Hub stopped successfully.');
    } catch (e) {
      _log('⚠️ [DISCONNECT] Error while stopping hub: $e', error: e);
    } finally {
      _emitStatus(DispatcherMapConnectionStatus.disconnected);
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _log('🧹 [DISPOSE] Disposing SignalR client and closing streams.');

    _owners.clear();
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;

    _removeHandlers();
    try {
      await _hubConnection?.stop();
    } catch (_) {}

    _hubConnection = null;
    await _eventController.close();
    await _connectionStatusController.close();
  }
}

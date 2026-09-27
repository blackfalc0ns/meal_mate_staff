import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:signalr_netcore/signalr_client.dart';

import '../../../../../core/network/network_constants.dart';
import '../../../../../core/services/token_service.dart';
import '../models/realtime/driver_availability_updated_event_dto.dart';
import 'dispatcher_drivers_status_realtime_client.dart';

class DispatcherDriversStatusSignalRClient
    implements DispatcherDriversStatusRealtimeClient {
  DispatcherDriversStatusSignalRClient(
    this._tokenService, {
    String? hubUrl,
    HubConnection? hubConnection,
  }) : _customHubUrl = hubUrl,
       _providedHubConnection = hubConnection;

  final TokenService _tokenService;
  final String? _customHubUrl;
  final HubConnection? _providedHubConnection;

  HubConnection? _hubConnection;
  final Set<String> _owners = <String>{};
  bool _isDisposed = false;
  bool _handlersRegistered = false;

  final StreamController<DriverAvailabilityUpdatedEventDto> _eventsController =
      StreamController<DriverAvailabilityUpdatedEventDto>.broadcast();

  @override
  Stream<DriverAvailabilityUpdatedEventDto> get events =>
      _eventsController.stream;

  Set<String> get activeOwners => Set.unmodifiable(_owners);
  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  static String buildHubUrl({String? base}) {
    final raw = base ?? NetworkConstants.baseUrl;
    final uri = Uri.parse(raw);
    final normalizedPath = uri.path.endsWith('/')
        ? '${uri.path}hubs/dispatcher-hub'
        : uri.path.isEmpty || uri.path == '/'
        ? '/hubs/dispatcher-hub'
        : '${uri.path}/hubs/dispatcher-hub';
    return uri.replace(path: normalizedPath).toString();
  }

  String get _resolvedHubUrl => _customHubUrl ?? buildHubUrl();

  void _log(String message) {
    developer.log(message, name: 'DispatcherDriversSignalR');
  }

  void _ensureHubBuilt(String token) {
    if (_hubConnection != null) return;

    if (_providedHubConnection != null) {
      _hubConnection = _providedHubConnection;
    } else {
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            _resolvedHubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
            ),
          )
          .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
          .build();
    }

    _registerHandlers();
  }

  void _registerHandlers() {
    if (_handlersRegistered || _hubConnection == null) return;

    _hubConnection!.on(
      'driver-availability-updated',
      _handleDriverAvailabilityUpdated,
    );
    _handlersRegistered = true;
  }

  void _removeHandlers() {
    if (!_handlersRegistered || _hubConnection == null) return;

    _hubConnection!.off('driver-availability-updated');
    _handlersRegistered = false;
  }

  void _handleDriverAvailabilityUpdated(List<dynamic>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final raw = arguments.first;
      Map<String, dynamic>? data;

      if (raw is Map) {
        data = Map<String, dynamic>.from(raw);
      } else if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      }

      if (data == null) return;

      final eventDto = DriverAvailabilityUpdatedEventDto.fromJson(data);
      if (eventDto.driverId.trim().isEmpty) return;

      if (!_eventsController.isClosed) {
        _eventsController.add(eventDto);
      }
    } catch (e) {
      _log('Failed to parse driver-availability-updated: $e');
    }
  }

  @override
  Future<void> acquire(String ownerId) async {
    if (_isDisposed) return;
    _owners.add(ownerId);
    _log('Owner acquired: $ownerId (total: ${_owners.length})');

    final token = await _tokenService.getToken();
    if (token == null || token.isEmpty) {
      _log('Cannot connect: token is empty');
      return;
    }

    _ensureHubBuilt(token);

    if (_hubConnection?.state != HubConnectionState.Connected &&
        _hubConnection?.state != HubConnectionState.Connecting) {
      try {
        await _hubConnection?.start();
        _log('SignalR connected to $_resolvedHubUrl');
      } catch (e) {
        _log('SignalR connect error: $e');
      }
    }
  }

  @override
  Future<void> release(String ownerId) async {
    _owners.remove(ownerId);
    _log('Owner released: $ownerId (remaining: ${_owners.length})');

    if (_owners.isEmpty && _hubConnection != null) {
      try {
        await _hubConnection?.stop();
        _log('SignalR disconnected (no active owners)');
      } catch (e) {
        _log('SignalR disconnect error: $e');
      }
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _owners.clear();
    _removeHandlers();

    try {
      await _hubConnection?.stop();
    } catch (_) {}

    await _eventsController.close();
  }
}

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:driver_voice_engine/driver_voice_engine.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/services.dart';

import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/network_constants.dart';
import '../../../../../core/services/server_clock.dart';
import '../../../../../core/services/token_service.dart';
import '../../../../../core/services/voice_device_session_storage.dart';
import '../../domain/entities/delivery_contact_case_entity.dart';
import '../../domain/entities/ice_server_config_entity.dart';
import '../../domain/entities/phone_grant_entity.dart';
import '../../domain/entities/voice_call_display_entity.dart';
import '../../domain/entities/voice_call_eligibility_entity.dart';
import '../../domain/entities/voice_call_snapshot_entity.dart';
import '../../domain/entities/voice_call_status.dart';
import '../../domain/entities/voice_device_session_entity.dart';
import '../../domain/repo/driver_calling_repository.dart';
import '../callkit/driver_callkit_coordinator.dart';
import '../data_source/driver_calling_remote_data_source.dart';
import '../mapper/calling_dto_mapper.dart';
import '../models/request/delivery_contact_hold_request_dto.dart';
import '../models/request/delivery_contact_resume_request_dto.dart';
import '../models/request/delivery_contact_reveal_phone_request_dto.dart';
import '../models/request/voice_call_initiate_request_dto.dart';
import '../models/request/voice_device_register_request_dto.dart';
import '../models/response/voice_call_snapshot_response_dto.dart';
import '../realtime/driver_voice_call_signalr_client.dart';
import '../webrtc/driver_webrtc_manager.dart';

typedef HeartbeatTimerFactory =
    Timer Function(Duration duration, void Function(Timer timer) callback);

@Injectable(as: DriverCallingRepository)
class DriverCallingRepositoryImpl implements DriverCallingRepository {
  DriverCallingRepositoryImpl({
    required this.remoteDataSource,
    required this.signalRClient,
    required this.webrtcManager,
    required this.callKitCoordinator,
    required this.sessionStorage,
    this.tokenService,
    DriverVoiceEngine? driverVoiceEngine,
    bool useNativeEngine = true,
    ServerClock? serverClock,
    HeartbeatTimerFactory? heartbeatTimerFactory,
  }) : _heartbeatTimerFactory = heartbeatTimerFactory ?? Timer.periodic,
       _serverClock = serverClock ?? ServerClock(),
       _driverVoiceEngine = driverVoiceEngine,
       _useNativeEngine = useNativeEngine && driverVoiceEngine != null {
    _initListeners();
  }

  final DriverCallingRemoteDataSource remoteDataSource;
  final DriverVoiceCallSignalRClient signalRClient;
  final DriverWebRtcManager webrtcManager;
  final DriverCallKitCoordinator callKitCoordinator;
  final VoiceDeviceSessionStorage sessionStorage;
  final TokenService? tokenService;
  final DriverVoiceEngine? _driverVoiceEngine;
  final bool _useNativeEngine;
  final HeartbeatTimerFactory _heartbeatTimerFactory;
  final ServerClock _serverClock;

  final _snapshotController =
      StreamController<VoiceCallSnapshotEntity>.broadcast();
  final _statusController = StreamController<VoiceCallStatus>.broadcast();

  String? _activeCallId;
  int _currentGeneration = 0;
  int _sessionToken = 0;
  VoiceCallSnapshotEntity? _currentSnapshot;
  String? _callKitStartedCallId;
  Future<void>? _deviceRegistrationInFlight;

  Timer? _heartbeatTimer;
  String? _heartbeatCallId;
  bool _heartbeatRequestInFlight = false;

  final Set<String> _connectingInFlight = {};
  final Set<String> _reportedConnecting = {};
  final Set<String> _connectedInFlight = {};
  final Set<String> _reportedConnected = {};

  String? _webRtcOfferInFlightKey;
  final Set<String> _startedWebRtcOfferKeys = {};

  Future<void> _ensureVoiceDeviceSession() {
    if (sessionStorage.isSessionValid()) return Future.value();
    final inFlight = _deviceRegistrationInFlight;
    if (inFlight != null) return inFlight;

    final future = _registerStoredDevice();
    _deviceRegistrationInFlight = future;
    return future.whenComplete(() => _deviceRegistrationInFlight = null);
  }

  Future<void> _registerStoredDevice() async {
    final fcmDeviceTokenId = sessionStorage.getFcmDeviceTokenId();
    if (fcmDeviceTokenId == null || fcmDeviceTokenId.trim().isEmpty) {
      throw StateError(
        'Voice device registration requires an FCM device token id',
      );
    }
    final result = await registerVoiceDevice(
      fcmDeviceTokenId: fcmDeviceTokenId,
      platform: Platform.isIOS ? 'ios' : 'android',
      deviceId: sessionStorage.getOrCreateInstallationId('voice-device'),
    );
    if (result case ApiErrorResult(:final failure)) {
      throw StateError(failure.errorMessage);
    }
  }

  @override
  Stream<VoiceCallSnapshotEntity> get onSnapshotUpdated =>
      _snapshotController.stream;

  @override
  Stream<VoiceCallStatus> get onStatusChanged => _statusController.stream;

  void _initListeners() {
    if (_useNativeEngine) {
      _driverVoiceEngine!.onSnapshotUpdated.listen((nativeSnapshot) {
        final entity = _mapNativeSnapshot(nativeSnapshot);
        _handleNativeSnapshot(entity);
      });
      return;
    }

    callKitCoordinator.initialize();

    // SignalR lifecycle envelope events
    signalRClient.onEnvelopeReceived.listen((envelope) {
      final payload = envelope.payload != null
          ? Map<String, dynamic>.from(envelope.payload!)
          : <String, dynamic>{};
      payload['callId'] ??= envelope.callId;
      payload['sequence'] ??= envelope.sequence;
      _handleEnvelope(payload);
    });

    // Reconnected callback from SignalR
    signalRClient.onReconnected = () {
      unawaited(_reconcileAfterReconnect());
    };

    // WebRTC connection state changes (connecting, etc.)
    webrtcManager.onMediaStateChanged.listen(_statusController.add);

    // Local WebRTC media connection
    webrtcManager.onLocalMediaConnected.listen((connected) {
      if (connected && _activeCallId != null) {
        _diag(
          'WebRTC',
          'Local media connected for call $_activeCallId, sending /reports/connected',
          callId: _activeCallId,
          gen: _currentGeneration,
        );
        if (_currentSnapshot?.status == VoiceCallStatus.active) {
          unawaited(callKitCoordinator.setCallConnected(_activeCallId!));
        }
        unawaited(_sendConnectedReport(_activeCallId!, _currentGeneration));
      }
    });

    // Native CallKit actions (user ends call natively or timeout)
    callKitCoordinator.onCallKitAction.listen((event) {
      if (event.callId == null || event.callId != _activeCallId) return;
      final action = event.action;
      if (action == 'end' && _activeCallId != null) {
        final status = _currentSnapshot?.status;
        _diag(
          'CallKit',
          'CallKit user end action received for status $status',
          callId: _activeCallId,
        );
        if (status == VoiceCallStatus.created ||
            status == VoiceCallStatus.ringing) {
          unawaited(cancelCall(_activeCallId!));
        } else if (status == VoiceCallStatus.accepted ||
            status == VoiceCallStatus.connecting ||
            status == VoiceCallStatus.active) {
          unawaited(endCall(_activeCallId!));
        } else {
          unawaited(cleanupCall());
        }
      } else if (action == 'timeout' && _activeCallId != null) {
        _diag(
          'CallKit',
          'CallKit timeout action received for call $_activeCallId',
          callId: _activeCallId,
        );
        unawaited(_handleCallKitTimeout(_activeCallId!));
      } else if (action == 'mute') {
        unawaited(toggleMute(true));
      }
    });
  }

  Future<void> _sendConnectingReport(
    String callId,
    int generation, {
    int retryCount = 0,
  }) async {
    final key = '$callId:$generation';
    if (_reportedConnecting.contains(key)) return;
    if (_connectingInFlight.contains(key)) return;

    _connectingInFlight.add(key);
    _diag(
      'Report',
      'Reporting /reports/connecting (attempt ${retryCount + 1})',
      callId: callId,
      gen: generation,
    );

    try {
      final result = await reportConnecting(callId);
      if (result is ApiSuccessResult) {
        _reportedConnecting.add(key);
        _diag(
          'Report',
          'Successfully reported /reports/connecting',
          callId: callId,
          gen: generation,
        );
      } else if (result case ApiErrorResult(:final failure)) {
        _diag(
          'Report',
          'Failed /reports/connecting: ${failure.errorMessage}',
          callId: callId,
          gen: generation,
        );
        if (retryCount < 2 &&
            _activeCallId == callId &&
            _currentGeneration == generation &&
            (_currentSnapshot == null || !_currentSnapshot!.isTerminal)) {
          unawaited(
            Future.delayed(const Duration(seconds: 2), () {
              if (_activeCallId == callId &&
                  _currentGeneration == generation &&
                  !_reportedConnecting.contains(key)) {
                unawaited(
                  _sendConnectingReport(
                    callId,
                    generation,
                    retryCount: retryCount + 1,
                  ),
                );
              }
            }),
          );
        }
      }
    } finally {
      _connectingInFlight.remove(key);
    }
  }

  Future<void> _sendConnectedReport(
    String callId,
    int generation, {
    int retryCount = 0,
  }) async {
    final key = '$callId:$generation';
    if (_reportedConnected.contains(key)) return;
    if (_connectedInFlight.contains(key)) return;

    _connectedInFlight.add(key);
    _diag(
      'Report',
      'Reporting /reports/connected (attempt ${retryCount + 1})',
      callId: callId,
      gen: generation,
    );

    try {
      final result = await reportConnected(callId);
      if (result is ApiSuccessResult) {
        _reportedConnected.add(key);
        _diag(
          'Report',
          'Successfully reported /reports/connected',
          callId: callId,
          gen: generation,
        );
      } else if (result case ApiErrorResult(:final failure)) {
        _diag(
          'Report',
          'Failed /reports/connected: ${failure.errorMessage}',
          callId: callId,
          gen: generation,
        );
        if (retryCount < 2 &&
            _activeCallId == callId &&
            _currentGeneration == generation &&
            (_currentSnapshot == null || !_currentSnapshot!.isTerminal)) {
          unawaited(
            Future.delayed(const Duration(seconds: 2), () {
              if (_activeCallId == callId &&
                  _currentGeneration == generation &&
                  !_reportedConnected.contains(key)) {
                unawaited(
                  _sendConnectedReport(
                    callId,
                    generation,
                    retryCount: retryCount + 1,
                  ),
                );
              }
            }),
          );
        }
      }
    } finally {
      _connectedInFlight.remove(key);
    }
  }

  Future<void> _reconcileAfterReconnect() async {
    _diag('Reconnect', 'Reconciling active call after reconnect');
    final activeResult = await getActiveCall();
    switch (activeResult) {
      case ApiSuccessResult(:final data):
        if (data == null || data.isTerminal) {
          _diag(
            'Reconnect',
            'No active call or terminal call found on server. Cleaning up UI.',
          );
          await cleanupCall();
        } else {
          _handleSnapshot(data);
        }
      case ApiErrorResult(:final failure):
        _diag(
          'Reconnect',
          'Failed to retrieve active call on reconnect: ${failure.errorMessage}',
        );
    }
  }

  void _handleEnvelope(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final snapshotDto = VoiceCallSnapshotResponseDto.fromJson(payload);
      final snapshot = CallingDtoMapper.toSnapshotEntity(snapshotDto);
      _handleSnapshot(snapshot);
    } catch (e) {
      _diag('Envelope', 'Error parsing envelope payload: $e');
    }
  }

  void _handleSnapshot(VoiceCallSnapshotEntity snapshot) {
    // Foreign call check: if there is an active non-terminal call and snapshot.callId doesn't match
    if (_activeCallId != null && _activeCallId != snapshot.callId) {
      if (_currentSnapshot != null && !_currentSnapshot!.isTerminal) {
        _diag(
          'Snapshot',
          'Rejecting foreign call event: active=$_activeCallId incoming=${snapshot.callId}',
          callId: snapshot.callId,
        );
        return;
      }
    }

    // Monotonic sequence and state regression checks for the same call
    if (_currentSnapshot != null &&
        _currentSnapshot!.callId == snapshot.callId) {
      // Never let a non-terminal snapshot reopen an already terminal call
      if (_currentSnapshot!.isTerminal && !snapshot.isTerminal) {
        _diag(
          'Snapshot',
          'Rejecting non-terminal snapshot for already terminal call',
          callId: snapshot.callId,
        );
        return;
      }

      // Reject lower or equal committed sequence
      if (snapshot.sequence <= _currentSnapshot!.sequence) {
        _diag(
          'Snapshot',
          'Ignoring older or equal sequence: ${snapshot.sequence} <= ${_currentSnapshot!.sequence}',
          callId: snapshot.callId,
          seq: snapshot.sequence,
        );
        return;
      }

      // Never revert progressed state (accepted/connecting/active) back to created/ringing
      final currentStatus = _currentSnapshot!.status;
      final incomingStatus = snapshot.status;
      final isCurrentlyProgressed =
          currentStatus == VoiceCallStatus.accepted ||
          currentStatus == VoiceCallStatus.connecting ||
          currentStatus == VoiceCallStatus.active;
      final isIncomingEarly =
          incomingStatus == VoiceCallStatus.created ||
          incomingStatus == VoiceCallStatus.ringing;
      if (isCurrentlyProgressed && isIncomingEarly) {
        _diag(
          'Snapshot',
          'Rejecting regression from $currentStatus to $incomingStatus',
          callId: snapshot.callId,
          seq: snapshot.sequence,
        );
        return;
      }
    }

    if (_activeCallId == null && !snapshot.isTerminal) {
      _activeCallId = snapshot.callId;
    }

    _currentSnapshot = snapshot;
    _snapshotController.add(snapshot);
    _statusController.add(snapshot.status);

    _diag(
      'Snapshot',
      'Applied snapshot: status=${snapshot.status}, connectedAtUtc=${snapshot.connectedAtUtc}',
      callId: snapshot.callId,
      seq: snapshot.sequence,
    );

    // Heartbeat lifecycle management
    _startHeartbeatForSnapshot(snapshot);

    // When customer answers (Accepted), driver initiates WebRTC offer!
    if (snapshot.status == VoiceCallStatus.accepted) {
      unawaited(_triggerWebRtcOffer(snapshot.callId));
    }

    // Set CallKit call connected only after authoritative Active state
    if (snapshot.status == VoiceCallStatus.active && _activeCallId != null) {
      unawaited(callKitCoordinator.setCallConnected(_activeCallId!));
    }

    // Terminal cleanup
    if (snapshot.status.isTerminal) {
      unawaited(cleanupCall(snapshot.callId));
    }
  }

  void _handleNativeSnapshot(VoiceCallSnapshotEntity snapshot) {
    if (_activeCallId != null && _activeCallId != snapshot.callId) {
      if (_currentSnapshot != null && !_currentSnapshot!.isTerminal) {
        _diag(
          'NativeSnapshot',
          'Rejecting foreign call event: active=$_activeCallId incoming=${snapshot.callId}',
          callId: snapshot.callId,
        );
        return;
      }
    }

    if (_currentSnapshot != null &&
        _currentSnapshot!.callId == snapshot.callId) {
      if (_currentSnapshot!.isTerminal && !snapshot.isTerminal) {
        _diag(
          'NativeSnapshot',
          'Rejecting non-terminal snapshot for already terminal call',
          callId: snapshot.callId,
        );
        return;
      }
      if (snapshot.sequence < _currentSnapshot!.sequence) {
        _diag(
          'NativeSnapshot',
          'Ignoring older sequence: ${snapshot.sequence} < ${_currentSnapshot!.sequence}',
          callId: snapshot.callId,
          seq: snapshot.sequence,
        );
        return;
      }
    }

    if (_activeCallId == null && !snapshot.isTerminal) {
      _activeCallId = snapshot.callId;
    }

    _currentSnapshot = snapshot;
    _snapshotController.add(snapshot);
    _statusController.add(snapshot.status);

    _diag(
      'NativeSnapshot',
      'Applied native snapshot: status=${snapshot.status}, connectedAtUtc=${snapshot.connectedAtUtc}',
      callId: snapshot.callId,
      seq: snapshot.sequence,
    );

    if (snapshot.status.isTerminal) {
      _activeCallId = null;
    }
  }

  VoiceCallSnapshotEntity _mapNativeSnapshot(DriverVoiceCallSnapshot s) {
    final status = switch (s.serverStatus) {
      DriverVoiceServerCallStatus.idle => VoiceCallStatus.created,
      DriverVoiceServerCallStatus.created => VoiceCallStatus.created,
      DriverVoiceServerCallStatus.ringing => VoiceCallStatus.ringing,
      DriverVoiceServerCallStatus.accepted => VoiceCallStatus.accepted,
      DriverVoiceServerCallStatus.connecting => VoiceCallStatus.connecting,
      DriverVoiceServerCallStatus.active => VoiceCallStatus.active,
      DriverVoiceServerCallStatus.rejected => VoiceCallStatus.rejected,
      DriverVoiceServerCallStatus.cancelled => VoiceCallStatus.cancelled,
      DriverVoiceServerCallStatus.missed => VoiceCallStatus.missed,
      DriverVoiceServerCallStatus.failed => VoiceCallStatus.failed,
      DriverVoiceServerCallStatus.ended => VoiceCallStatus.ended,
      DriverVoiceServerCallStatus.busy => VoiceCallStatus.failed,
      DriverVoiceServerCallStatus.unknown => VoiceCallStatus.created,
    };

    DateTime? parseIso(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      return DateTime.tryParse(raw);
    }

    return VoiceCallSnapshotEntity(
      callId: s.callId ?? '',
      tripStopId: s.tripStopId,
      protocolVersion: s.schemaVersion,
      sequence: s.serverSequence,
      status: status,
      endReason: s.terminationReason.name,
      connectedAtUtc: parseIso(s.connectedAtUtc),
      deadlineAtUtc: parseIso(s.deadlineAtUtc),
    );
  }

  void _startHeartbeatForSnapshot(VoiceCallSnapshotEntity snapshot) {
    final status = snapshot.status;
    final isHeartbeatEligible =
        status == VoiceCallStatus.accepted ||
        status == VoiceCallStatus.connecting ||
        status == VoiceCallStatus.active;

    if (!isHeartbeatEligible) {
      if (status.isTerminal) {
        _stopHeartbeat();
      }
      return;
    }

    if (_heartbeatTimer != null && _heartbeatCallId == snapshot.callId) {
      return;
    }

    _stopHeartbeat();
    _heartbeatCallId = snapshot.callId;
    _heartbeatTimer = _heartbeatTimerFactory(const Duration(seconds: 10), (
      timer,
    ) {
      unawaited(_heartbeatTick(snapshot.callId));
    });
    _diag(
      'Heartbeat',
      'Started 10s heartbeat timer for call ${snapshot.callId}',
      callId: snapshot.callId,
    );
  }

  void _stopHeartbeat() {
    if (_heartbeatTimer != null) {
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
      _diag('Heartbeat', 'Stopped heartbeat timer', callId: _heartbeatCallId);
    }
    _heartbeatCallId = null;
    _heartbeatRequestInFlight = false;
  }

  Future<void> _heartbeatTick(String callId) async {
    if (callId != _activeCallId ||
        _currentSnapshot == null ||
        _currentSnapshot!.isTerminal) {
      _diag(
        'Heartbeat',
        'Dropping heartbeat tick: call $callId is not active or is terminal',
        callId: callId,
      );
      _stopHeartbeat();
      return;
    }

    if (_heartbeatRequestInFlight) {
      _diag(
        'Heartbeat',
        'Skipping heartbeat tick: previous request still in flight',
        callId: callId,
      );
      return;
    }

    _heartbeatRequestInFlight = true;
    try {
      _diag(
        'Heartbeat',
        'Sending heartbeat tick for call $callId',
        callId: callId,
      );
      final result = await sendHeartbeat(callId);
      if (result case ApiErrorResult(:final failure)) {
        _diag(
          'Heartbeat',
          'Heartbeat failed: ${failure.errorMessage}',
          callId: callId,
        );
      }
    } catch (e) {
      _diag('Heartbeat', 'Heartbeat error: $e', callId: callId);
    } finally {
      _heartbeatRequestInFlight = false;
    }
  }

  Future<void> _triggerWebRtcOffer(String callId) async {
    final generation = _currentGeneration;
    final sessionToken = _sessionToken;
    final key = '$callId:$generation';
    if (_startedWebRtcOfferKeys.contains(key)) {
      _diag(
        'Media',
        'WebRTC offer already started for key $key, ignoring duplicate trigger',
        callId: callId,
        gen: _currentGeneration,
      );
      return;
    }
    if (_webRtcOfferInFlightKey == key) {
      _diag(
        'Media',
        'WebRTC offer already in flight for key $key, ignoring duplicate trigger',
        callId: callId,
        gen: _currentGeneration,
      );
      return;
    }

    _webRtcOfferInFlightKey = key;
    try {
      // Require a successful per-call ice-servers response
      final iceResult = await getIceServers(callId);
      if (!_isCurrentSession(callId, generation, sessionToken)) return;
      if (iceResult is! ApiSuccessResult<List<IceServerConfigEntity>> ||
          iceResult.data.isEmpty) {
        _diag(
          'Media',
          'Failed to retrieve valid ICE servers for call $callId, aborting WebRTC offer',
          callId: callId,
          gen: _currentGeneration,
        );
        _webRtcOfferInFlightKey = null;
        return;
      }

      final servers = iceResult.data;

      // Report connecting when genuinely entering connection setup
      await _sendConnectingReport(callId, generation);
      if (!_isCurrentSession(callId, generation, sessionToken)) return;

      _startedWebRtcOfferKeys.add(key);

      await webrtcManager.startOfferSession(
        callId: callId,
        iceServers: servers,
        generation: generation,
      );
    } catch (e) {
      _diag(
        'Media',
        'Error starting WebRTC offer session: $e',
        callId: callId,
        gen: _currentGeneration,
      );
      _startedWebRtcOfferKeys.remove(key);
    } finally {
      if (_webRtcOfferInFlightKey == key) {
        _webRtcOfferInFlightKey = null;
      }
    }
  }

  @override
  Future<ApiResult<VoiceDeviceSessionEntity>> registerVoiceDevice({
    required String fcmDeviceTokenId,
    required String platform,
    required String deviceId,
    int capabilityVersion = 2,
  }) async {
    return safeApiCall(() async {
      final installationId = sessionStorage.getOrCreateInstallationId(deviceId);
      final request = VoiceDeviceRegisterRequestDto(
        installationId: installationId,
        platform: platform,
        fcmDeviceTokenId: fcmDeviceTokenId,
        capabilityVersion: capabilityVersion,
      );
      _diag(
        'Register',
        'Registering voice device (capabilityVersion: $capabilityVersion)',
      );
      final response = await remoteDataSource.registerDevice(request);
      await sessionStorage.saveSession(
        deviceSessionId: response.deviceSessionId,
        controlProof: response.controlProof,
        expiresAtUtc: response.expiresAtUtc,
      );
      return CallingDtoMapper.toDeviceSessionEntity(response);
    });
  }

  @override
  Future<ApiResult<void>> revokeVoiceDevice() async {
    return safeApiCall(() async {
      if (_useNativeEngine) {
        await _driverVoiceEngine!.revokeAccountSession();
      }
      _stopHeartbeat();
      final sessionId = sessionStorage.getDeviceSessionId();
      if (sessionId != null) {
        try {
          await remoteDataSource.revokeDevice(sessionId);
        } catch (_) {}
      }
      await sessionStorage.clearSession();
      if (!_useNativeEngine) {
        await signalRClient.disconnect();
      }
    });
  }

  @override
  Future<ApiResult<VoiceCallEligibilityEntity>> checkEligibility(
    String tripStopId,
  ) async {
    return safeApiCall(() async {
      final response = await remoteDataSource.checkEligibility(tripStopId);
      return CallingDtoMapper.toEligibilityEntity(response);
    });
  }

  @override
  Future<ApiResult<VoiceCallSnapshotEntity>> initiateCall({
    required String tripStopId,
    required String clientRequestId,
  }) async {
    if (_useNativeEngine) {
      return safeApiCall(() async {
        _sessionToken++;
        final operationToken = _sessionToken;
        _currentGeneration = 0;

        await _ensureVoiceDeviceSession();
        if (_sessionToken != operationToken) {
          throw StateError('Call operation cancelled or superseded');
        }

        final token = await tokenService?.getToken() ?? '';
        final refreshToken = await tokenService?.getRefreshToken();
        final fcmDeviceTokenId = sessionStorage.getFcmDeviceTokenId();
        final installationId = sessionStorage.getOrCreateInstallationId(
          'voice-device',
        );

        await _driverVoiceEngine!.syncAccountSession(
          DriverVoiceAccountSession(
            accessToken: token,
            refreshToken: refreshToken,
            userId: 'current-driver',
            baseUrl: NetworkConstants.baseUrl,
            hubUrl: '${NetworkConstants.baseUrl}${EndPoints.voiceCallsV2Hub}',
            installationId: installationId,
            fcmDeviceTokenId: fcmDeviceTokenId,
            platform: Platform.isIOS ? 'ios' : 'android',
          ),
        );

        if (Platform.isAndroid &&
            identical(_driverVoiceEngine, DriverVoiceEngine.instance)) {
          // Reuse the exact session registered by Dart; registering again revokes it.
          await const MethodChannel(
            'mealmate/auth_session',
          ).invokeMethod<void>('syncVoiceDevice', {
            'deviceSessionId': sessionStorage.getDeviceSessionId(),
            'controlProof': await sessionStorage.getControlProof(),
            'expiresAtUtc': sessionStorage
                .getExpiresAtUtc()
                ?.toUtc()
                .toIso8601String(),
          });
        }

        final res = await _driverVoiceEngine.startOutgoing(
          tripStopId: tripStopId,
          clientRequestId: clientRequestId,
        );

        if (res.status != DriverVoiceCommandStatus.success) {
          throw StateError(
            res.errorMessage ??
                'Failed to start native call: ${res.status.name}',
          );
        }

        final nativeSnapshot = await _driverVoiceEngine.getCurrentCall();
        if (nativeSnapshot != null) {
          final entity = _mapNativeSnapshot(nativeSnapshot);
          _activeCallId = entity.callId;
          _currentSnapshot = entity;
          _snapshotController.add(entity);
          _statusController.add(entity.status);
          return entity;
        }

        final fallback = VoiceCallSnapshotEntity(
          callId: res.operationId ?? '',
          tripStopId: tripStopId,
          protocolVersion: 2,
          sequence: 1,
          status: VoiceCallStatus.created,
        );
        _activeCallId = fallback.callId;
        _currentSnapshot = fallback;
        _snapshotController.add(fallback);
        _statusController.add(fallback.status);
        return fallback;
      });
    }

    return safeApiCall(() async {
      _sessionToken++;
      final operationToken = _sessionToken;
      _currentGeneration = 0;
      _callKitStartedCallId = null;
      _webRtcOfferInFlightKey = null;
      _startedWebRtcOfferKeys.clear();
      _connectingInFlight.clear();
      _reportedConnecting.clear();
      _connectedInFlight.clear();
      _reportedConnected.clear();

      await _ensureVoiceDeviceSession();
      if (_sessionToken != operationToken) {
        _diag(
          'Initiate',
          'Session token changed during device session ensure, aborting initiate',
        );
        throw StateError('Call operation cancelled or superseded');
      }

      // Connect and bind SignalR hub
      await connectSignalR();
      if (_sessionToken != operationToken) {
        _diag(
          'Initiate',
          'Session token changed during connectSignalR, aborting initiate',
        );
        throw StateError('Call operation cancelled or superseded');
      }

      final request = VoiceCallInitiateRequestDto(
        tripStopId: tripStopId,
        clientRequestId: clientRequestId,
      );
      _diag(
        'Initiate',
        'Initiating call with clientRequestId: $clientRequestId',
      );
      final response = await remoteDataSource.initiateCall(request);
      final snapshot = CallingDtoMapper.toSnapshotEntity(response);

      // Verify operation identity after initiateCall await
      if (_sessionToken != operationToken) {
        _diag(
          'Initiate',
          'Session token changed while waiting for initiateCall response, ignoring late REST response',
          callId: snapshot.callId,
        );
        if (_currentSnapshot != null &&
            _currentSnapshot!.callId == snapshot.callId) {
          return _currentSnapshot!;
        }
        return snapshot;
      }

      _activeCallId = snapshot.callId;
      _handleSnapshot(snapshot);

      // Start CallKit outgoing call UI only if still ringing/created, not terminal, and not yet started
      final current = _currentSnapshot ?? snapshot;
      if (!current.isTerminal &&
          current.status != VoiceCallStatus.accepted &&
          current.status != VoiceCallStatus.connecting &&
          current.status != VoiceCallStatus.active &&
          _callKitStartedCallId != snapshot.callId) {
        _callKitStartedCallId = snapshot.callId;
        final nowUtc = _serverClock.nowUtcOrLocal;
        Duration ringTimeout;
        if (current.deadlineAtUtc != null) {
          ringTimeout = current.deadlineAtUtc!.difference(nowUtc);
        } else {
          ringTimeout = const Duration(seconds: 30);
        }

        if (ringTimeout <= Duration.zero) {
          _diag(
            'Initiate',
            'Call initiated with expired deadline, handling as timeout',
            callId: snapshot.callId,
          );
          unawaited(_handleCallKitTimeout(snapshot.callId));
        } else {
          // Start CallKit outgoing call UI with derived duration
          await callKitCoordinator.startOutgoingCall(
            callId: snapshot.callId,
            customerName: 'Customer',
            ringTimeout: ringTimeout,
          );
        }
      }

      return _currentSnapshot ?? snapshot;
    });
  }

  Future<void> _handleCallKitTimeout(String callId) async {
    _diag(
      'CallKit',
      'Handling CallKit timeout for call $callId',
      callId: callId,
    );
    final snapshotResult = await getCallSnapshot(callId);
    final status = switch (snapshotResult) {
      ApiSuccessResult(:final data) => data.status,
      _ => _currentSnapshot?.status,
    };

    if (status == VoiceCallStatus.accepted ||
        status == VoiceCallStatus.connecting ||
        status == VoiceCallStatus.active) {
      _diag(
        'CallKit',
        'Ignoring CallKit timeout: call is in active state ($status)',
        callId: callId,
      );
      return;
    }

    if (status == VoiceCallStatus.created ||
        status == VoiceCallStatus.ringing) {
      _diag(
        'CallKit',
        'Call timed out while ringing/created, cancelling call',
        callId: callId,
      );
      await cancelCall(callId);
    } else {
      await cleanupCall(callId);
    }
  }

  @override
  Future<ApiResult<void>> cancelCall(String callId) async {
    if (_useNativeEngine) {
      return safeApiCall(() async {
        _diag('Cancel', 'Cancelling native call $callId', callId: callId);
        final res = await _driverVoiceEngine!.hangUp('cancelled');
        if (res.status != DriverVoiceCommandStatus.success) {
          throw StateError(res.errorMessage ?? 'Failed to cancel call');
        }
        _activeCallId = null;
        _currentSnapshot = null;
      });
    }

    return safeApiCall(() async {
      _diag('Cancel', 'Cancelling call $callId', callId: callId);
      await remoteDataSource.cancelCall(callId);
      await cleanupCall(callId);
    });
  }

  @override
  Future<ApiResult<void>> endCall(String callId) async {
    if (_useNativeEngine) {
      return safeApiCall(() async {
        _diag('End', 'Ending native call $callId', callId: callId);
        final res = await _driverVoiceEngine!.hangUp('ended');
        if (res.status != DriverVoiceCommandStatus.success) {
          throw StateError(res.errorMessage ?? 'Failed to end call');
        }
        _activeCallId = null;
        _currentSnapshot = null;
      });
    }

    return safeApiCall(() async {
      _diag('End', 'Ending call $callId', callId: callId);
      await remoteDataSource.endCall(callId);
      await cleanupCall(callId);
    });
  }

  @override
  Future<ApiResult<VoiceCallSnapshotEntity?>> getActiveCall() async {
    if (_useNativeEngine) {
      return safeApiCall(() async {
        final nativeSnap = await _driverVoiceEngine!.getCurrentCall();
        if (nativeSnap != null &&
            nativeSnap.callId != null &&
            nativeSnap.callId!.isNotEmpty &&
            nativeSnap.serverStatus != DriverVoiceServerCallStatus.idle &&
            nativeSnap.serverStatus != DriverVoiceServerCallStatus.ended &&
            nativeSnap.serverStatus != DriverVoiceServerCallStatus.failed &&
            nativeSnap.serverStatus != DriverVoiceServerCallStatus.cancelled &&
            nativeSnap.serverStatus != DriverVoiceServerCallStatus.rejected &&
            nativeSnap.serverStatus != DriverVoiceServerCallStatus.missed) {
          final entity = _mapNativeSnapshot(nativeSnap);
          _activeCallId = entity.callId;
          _currentSnapshot = entity;
          return entity;
        }
        final response = await remoteDataSource.getActiveCall();
        if (response == null) return null;
        final snapshot = CallingDtoMapper.toSnapshotEntity(response);
        _activeCallId = snapshot.callId;
        _currentSnapshot = snapshot;
        return snapshot;
      });
    }

    return safeApiCall(() async {
      final response = await remoteDataSource.getActiveCall();
      if (response == null) return null;
      final snapshot = CallingDtoMapper.toSnapshotEntity(response);
      _activeCallId = snapshot.callId;
      _currentSnapshot = snapshot;
      return snapshot;
    });
  }

  @override
  Future<ApiResult<VoiceCallSnapshotEntity>> getCallSnapshot(
    String callId,
  ) async {
    if (_useNativeEngine) {
      return safeApiCall(() async {
        final current = await _driverVoiceEngine!.getCurrentCall();
        if (current != null && current.callId == callId) {
          final entity = _mapNativeSnapshot(current);
          _currentSnapshot = entity;
          return entity;
        }
        final response = await remoteDataSource.getCallSnapshot(callId);
        final snapshot = CallingDtoMapper.toSnapshotEntity(response);
        _currentSnapshot = snapshot;
        return snapshot;
      });
    }

    return safeApiCall(() async {
      final response = await remoteDataSource.getCallSnapshot(callId);
      final snapshot = CallingDtoMapper.toSnapshotEntity(response);
      _currentSnapshot = snapshot;
      return snapshot;
    });
  }

  @override
  Future<ApiResult<List<IceServerConfigEntity>>> getIceServers(
    String callId,
  ) async {
    return safeApiCall(() async {
      _diag(
        'IceServers',
        'Fetching ICE servers for call $callId',
        callId: callId,
      );
      final response = await remoteDataSource.getIceServers(callId);
      final servers = (response.iceServers ?? const [])
          .map(CallingDtoMapper.toIceServerEntity)
          .toList();
      return servers;
    });
  }

  @override
  Future<ApiResult<void>> reportConnecting(String callId) async {
    return safeApiCall(() async {
      await remoteDataSource.reportConnecting(callId);
    });
  }

  @override
  Future<ApiResult<void>> reportConnected(String callId) async {
    return safeApiCall(() async {
      await remoteDataSource.reportConnected(callId);
    });
  }

  @override
  Future<ApiResult<void>> sendHeartbeat(String callId) async {
    return safeApiCall(() async {
      await remoteDataSource.sendHeartbeat(callId);
    });
  }

  @override
  Future<ApiResult<DeliveryContactCaseEntity>> getContactCase(
    String tripStopId,
  ) async {
    return safeApiCall(() async {
      final response = await remoteDataSource.getContactCase(tripStopId);
      return CallingDtoMapper.toContactCaseEntity(response);
    });
  }

  @override
  Future<ApiResult<DeliveryContactCaseEntity>> holdContactCase({
    required String tripStopId,
    required String notes,
    required String firstAttemptCallId,
  }) async {
    return safeApiCall(() async {
      final request = DeliveryContactHoldRequestDto(
        notes: notes,
        firstAttemptCallId: firstAttemptCallId,
      );
      final response = await remoteDataSource.holdContactCase(
        tripStopId,
        request,
      );
      return CallingDtoMapper.toContactCaseEntity(response);
    });
  }

  @override
  Future<ApiResult<DeliveryContactCaseEntity>> resumeContactCase({
    required String tripStopId,
    double? lat,
    double? lng,
  }) async {
    return safeApiCall(() async {
      final request = DeliveryContactResumeRequestDto(lat: lat, lng: lng);
      final response = await remoteDataSource.resumeContactCase(
        tripStopId,
        request,
      );
      return CallingDtoMapper.toContactCaseEntity(response);
    });
  }

  @override
  Future<ApiResult<PhoneGrantEntity>> revealPhone({
    required String tripStopId,
    required String clientRequestId,
    required String reason,
  }) async {
    return safeApiCall(() async {
      final request = DeliveryContactRevealPhoneRequestDto(
        clientRequestId: clientRequestId,
        reason: reason,
        acknowledgedPrivacyWarning: true,
      );
      final response = await remoteDataSource.revealPhone(tripStopId, request);
      return CallingDtoMapper.toPhoneGrantEntity(response);
    });
  }

  @override
  Future<ApiResult<VoiceCallDisplayEntity>> getCallDisplay(
    String callId, {
    String? languageCode,
  }) async {
    return safeApiCall(() async {
      final response = await remoteDataSource.getCallDisplay(
        callId,
        languageCode: languageCode,
      );
      return CallingDtoMapper.toDisplayEntity(response);
    });
  }

  @override
  Future<void> connectSignalR() async {
    if (_useNativeEngine) return;
    await signalRClient.connect();
  }

  @override
  Future<void> disconnectSignalR() async {
    if (_useNativeEngine) return;
    await signalRClient.disconnect();
  }

  @override
  Future<void> startWebRtcCall({
    required String callId,
    required List<IceServerConfigEntity> iceServers,
  }) async {
    if (_useNativeEngine) return;
    await _triggerWebRtcOffer(callId);
  }

  @override
  Future<void> toggleMute(bool muted) async {
    if (_useNativeEngine) {
      await _driverVoiceEngine!.setMuted(muted);
      return;
    }
    await webrtcManager.toggleMute(muted);
  }

  @override
  Future<void> toggleSpeaker(bool enabled) async {
    if (_useNativeEngine) {
      await _driverVoiceEngine!.selectAudioRoute(
        enabled
            ? DriverVoiceAudioRoute.speaker
            : DriverVoiceAudioRoute.earpiece,
      );
      return;
    }
    await webrtcManager.toggleSpeaker(enabled);
  }

  @override
  Future<void> cleanupCall([String? targetCallId]) async {
    if (_useNativeEngine) {
      await _driverVoiceEngine!.hangUp('cleanup');
      _activeCallId = null;
      _currentSnapshot = null;
      return;
    }

    if (targetCallId != null &&
        _activeCallId != null &&
        _activeCallId != targetCallId) {
      _diag(
        'Cleanup',
        'Ignoring cleanup for mismatched callId: $targetCallId != $_activeCallId',
      );
      return;
    }
    final callIdToClean = _activeCallId ?? targetCallId;
    _diag(
      'Cleanup',
      'Performing idempotent call cleanup',
      callId: callIdToClean,
    );
    _sessionToken++;
    _stopHeartbeat();
    await callKitCoordinator.endCall(callIdToClean);
    await webrtcManager.cleanup(callIdToClean);
    signalRClient.resetSequenceAndDedupe(callIdToClean);
    _activeCallId = null;
    _callKitStartedCallId = null;
    _webRtcOfferInFlightKey = null;
    _startedWebRtcOfferKeys.clear();
    _connectingInFlight.clear();
    _reportedConnecting.clear();
    _connectedInFlight.clear();
    _reportedConnected.clear();
  }

  Future<void> terminateLocalAuthSession() async {
    _sessionToken++;
    _stopHeartbeat();
    if (!_useNativeEngine) {
      await callKitCoordinator.endCall(_activeCallId);
      await webrtcManager.cleanup(_activeCallId);
      await signalRClient.disconnect();
    }
    _activeCallId = null;
    _currentSnapshot = null;
    _statusController.add(VoiceCallStatus.failed);
    await sessionStorage.clearSession();
  }

  Future<void> reconcileAuthSession() async {
    if (!_useNativeEngine && _activeCallId != null) {
      await signalRClient.connect();
      await _reconcileAfterReconnect();
    }
  }

  bool _isCurrentSession(String callId, int generation, int token) {
    final snapshot = _currentSnapshot;
    return _sessionToken == token &&
        _activeCallId == callId &&
        _currentGeneration == generation &&
        snapshot != null &&
        !snapshot.isTerminal;
  }

  void _diag(
    String action,
    String details, {
    String? callId,
    int? seq,
    int? gen,
  }) {
    final c = callId != null && callId.isNotEmpty ? '[$callId]' : '[no-call]';
    final g = gen != null ? '[gen:$gen]' : '';
    final s = seq != null ? '[seq:$seq]' : '';
    developer.log('[VoiceDiag]$c$g$s $action: $details');
  }
}

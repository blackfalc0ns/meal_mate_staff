import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
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

@Injectable(as: DriverCallingRepository)
class DriverCallingRepositoryImpl implements DriverCallingRepository {
  DriverCallingRepositoryImpl({
    required this.remoteDataSource,
    required this.signalRClient,
    required this.webrtcManager,
    required this.callKitCoordinator,
    required this.sessionStorage,
  }) {
    _initListeners();
  }

  final DriverCallingRemoteDataSource remoteDataSource;
  final DriverVoiceCallSignalRClient signalRClient;
  final DriverWebRtcManager webrtcManager;
  final DriverCallKitCoordinator callKitCoordinator;
  final VoiceDeviceSessionStorage sessionStorage;

  final _snapshotController =
      StreamController<VoiceCallSnapshotEntity>.broadcast();
  final _statusController = StreamController<VoiceCallStatus>.broadcast();

  String? _activeCallId;
  int _currentGeneration = 0;
  VoiceCallSnapshotEntity? _currentSnapshot;
  Future<void>? _deviceRegistrationInFlight;

  final Set<String> _reportedConnectingKeys = {};
  final Set<String> _reportedConnectedKeys = {};

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
    callKitCoordinator.initialize();

    // SignalR lifecycle envelope events
    signalRClient.onEnvelopeReceived.listen((envelope) {
      _handleEnvelope(envelope.payload);
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
        _diag('WebRTC', 'Local media connected for call $_activeCallId, sending /reports/connected', callId: _activeCallId, gen: _currentGeneration);
        unawaited(callKitCoordinator.setCallConnected(_activeCallId!));
        unawaited(_sendConnectedReport(_activeCallId!, _currentGeneration));
      }
    });

    // Native CallKit actions (user ends call natively)
    callKitCoordinator.onCallKitAction.listen((action) {
      if (action == 'end' && _activeCallId != null) {
        final status = _currentSnapshot?.status;
        _diag('CallKit', 'CallKit end action received for status $status', callId: _activeCallId);
        if (status == VoiceCallStatus.created || status == VoiceCallStatus.ringing) {
          unawaited(cancelCall(_activeCallId!));
        } else if (status == VoiceCallStatus.accepted ||
            status == VoiceCallStatus.connecting ||
            status == VoiceCallStatus.active) {
          unawaited(endCall(_activeCallId!));
        } else {
          unawaited(cleanupCall());
        }
      } else if (action == 'mute') {
        unawaited(toggleMute(true));
      }
    });
  }

  Future<void> _sendConnectingReport(String callId, int generation) async {
    final key = '$callId:$generation';
    if (_reportedConnectingKeys.contains(key)) return;
    _reportedConnectingKeys.add(key);

    _diag('Report', 'Reporting /reports/connecting', callId: callId, gen: generation);
    final result = await reportConnecting(callId);
    if (result case ApiErrorResult(:final failure)) {
      _diag('Report', 'Failed /reports/connecting: ${failure.errorMessage}', callId: callId, gen: generation);
    }
  }

  Future<void> _sendConnectedReport(String callId, int generation) async {
    final key = '$callId:$generation';
    if (_reportedConnectedKeys.contains(key)) return;
    _reportedConnectedKeys.add(key);

    _diag('Report', 'Reporting /reports/connected', callId: callId, gen: generation);
    final result = await reportConnected(callId);
    if (result case ApiErrorResult(:final failure)) {
      _diag('Report', 'Failed /reports/connected: ${failure.errorMessage}', callId: callId, gen: generation);
    }
  }

  Future<void> _reconcileAfterReconnect() async {
    _diag('Reconnect', 'Reconciling active call after reconnect');
    final activeResult = await getActiveCall();
    switch (activeResult) {
      case ApiSuccessResult(:final data):
        if (data == null || data.isTerminal) {
          _diag('Reconnect', 'No active call or terminal call found on server. Cleaning up UI.');
          await cleanupCall();
        } else {
          _handleSnapshot(data);
        }
      case ApiErrorResult(:final failure):
        _diag('Reconnect', 'Failed to retrieve active call on reconnect: ${failure.errorMessage}');
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
    // Monotonic sequence verification
    if (_currentSnapshot != null &&
        _currentSnapshot!.callId == snapshot.callId &&
        snapshot.sequence < _currentSnapshot!.sequence) {
      _diag('Snapshot', 'Ignoring older sequence: ${snapshot.sequence} < ${_currentSnapshot!.sequence}', callId: snapshot.callId, seq: snapshot.sequence);
      return;
    }

    _currentSnapshot = snapshot;
    _snapshotController.add(snapshot);
    _statusController.add(snapshot.status);

    _diag('Snapshot', 'Applied snapshot: status=${snapshot.status}, connectedAtUtc=${snapshot.connectedAtUtc}', callId: snapshot.callId, seq: snapshot.sequence);

    // When customer answers (Accepted), driver initiates WebRTC offer!
    if (snapshot.status == VoiceCallStatus.accepted) {
      unawaited(_triggerWebRtcOffer(snapshot.callId));
    }

    // Terminal cleanup
    if (snapshot.status.isTerminal) {
      unawaited(cleanupCall());
    }
  }

  Future<void> _triggerWebRtcOffer(String callId) async {
    try {
      // Require a successful per-call ice-servers response
      final iceResult = await getIceServers(callId);
      if (iceResult is! ApiSuccessResult<List<IceServerConfigEntity>> ||
          iceResult.data.isEmpty) {
        _diag('Media', 'Failed to retrieve valid ICE servers for call $callId, aborting WebRTC offer', callId: callId, gen: _currentGeneration);
        return;
      }

      final servers = iceResult.data;

      // Report connecting when genuinely entering connection setup
      await _sendConnectingReport(callId, _currentGeneration);

      await webrtcManager.startOfferSession(
        callId: callId,
        iceServers: servers,
        generation: _currentGeneration,
      );
    } catch (e) {
      _diag('Media', 'Error starting WebRTC offer session: $e', callId: callId, gen: _currentGeneration);
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
      _diag('Register', 'Registering voice device (capabilityVersion: $capabilityVersion)');
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
      final sessionId = sessionStorage.getDeviceSessionId();
      if (sessionId != null) {
        try {
          await remoteDataSource.revokeDevice(sessionId);
        } catch (_) {}
      }
      await sessionStorage.clearSession();
      await signalRClient.disconnect();
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
    return safeApiCall(() async {
      await _ensureVoiceDeviceSession();
      // Connect and bind SignalR hub
      await connectSignalR();

      final request = VoiceCallInitiateRequestDto(
        tripStopId: tripStopId,
        clientRequestId: clientRequestId,
      );
      _diag('Initiate', 'Initiating call with clientRequestId: $clientRequestId');
      final response = await remoteDataSource.initiateCall(request);
      final snapshot = CallingDtoMapper.toSnapshotEntity(response);

      _activeCallId = snapshot.callId;
      _currentGeneration = 0;
      _currentSnapshot = snapshot;
      _reportedConnectingKeys.clear();
      _reportedConnectedKeys.clear();

      // Start CallKit outgoing call UI
      await callKitCoordinator.startOutgoingCall(
        callId: snapshot.callId,
        customerName: 'Customer',
      );

      _snapshotController.add(snapshot);
      _statusController.add(snapshot.status);

      return snapshot;
    });
  }

  @override
  Future<ApiResult<void>> cancelCall(String callId) async {
    return safeApiCall(() async {
      _diag('Cancel', 'Cancelling call $callId', callId: callId);
      await remoteDataSource.cancelCall(callId);
      await cleanupCall();
    });
  }

  @override
  Future<ApiResult<void>> endCall(String callId) async {
    return safeApiCall(() async {
      _diag('End', 'Ending call $callId', callId: callId);
      await remoteDataSource.endCall(callId);
      await cleanupCall();
    });
  }

  @override
  Future<ApiResult<VoiceCallSnapshotEntity?>> getActiveCall() async {
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
      _diag('IceServers', 'Fetching ICE servers for call $callId', callId: callId);
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
    await signalRClient.connect();
  }

  @override
  Future<void> disconnectSignalR() async {
    await signalRClient.disconnect();
  }

  @override
  Future<void> startWebRtcCall({
    required String callId,
    required List<IceServerConfigEntity> iceServers,
  }) async {
    await _triggerWebRtcOffer(callId);
  }

  @override
  Future<void> toggleMute(bool muted) async {
    await webrtcManager.toggleMute(muted);
  }

  @override
  Future<void> toggleSpeaker(bool enabled) async {
    await webrtcManager.toggleSpeaker(enabled);
  }

  @override
  Future<void> cleanupCall() async {
    _diag('Cleanup', 'Performing idempotent call cleanup', callId: _activeCallId);
    await callKitCoordinator.endCall(_activeCallId);
    await webrtcManager.cleanup();
    signalRClient.resetSequenceAndDedupe();
    _activeCallId = null;
    _reportedConnectingKeys.clear();
    _reportedConnectedKeys.clear();
  }

  void _diag(String action, String details, {String? callId, int? seq, int? gen}) {
    final c = callId != null && callId.isNotEmpty ? '[$callId]' : '[no-call]';
    final g = gen != null ? '[gen:$gen]' : '';
    final s = seq != null ? '[seq:$seq]' : '';
    developer.log('[VoiceDiag]$c$g$s $action: $details');
  }
}

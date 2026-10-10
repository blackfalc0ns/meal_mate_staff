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
  VoiceCallSnapshotEntity? _currentSnapshot;
  List<IceServerConfigEntity>? _cachedIceServers;
  Future<void>? _deviceRegistrationInFlight;

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

    // WebRTC connection state changes (connecting -> active)
    webrtcManager.onMediaStateChanged.listen((status) {
      _statusController.add(status);
      if (status == VoiceCallStatus.active && _activeCallId != null) {
        unawaited(callKitCoordinator.setCallConnected(_activeCallId!));
      }
    });

    // Native CallKit actions (user ends call natively)
    callKitCoordinator.onCallKitAction.listen((action) {
      if (action == 'end' && _activeCallId != null) {
        unawaited(endCall(_activeCallId!));
      } else if (action == 'mute') {
        unawaited(toggleMute(true));
      }
    });
  }

  void _handleEnvelope(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final snapshotDto = VoiceCallSnapshotResponseDto.fromJson(payload);
      final snapshot = CallingDtoMapper.toSnapshotEntity(snapshotDto);

      // Monotonic sequence verification
      if (_currentSnapshot != null &&
          snapshot.sequence < _currentSnapshot!.sequence) {
        return;
      }

      _currentSnapshot = snapshot;
      _snapshotController.add(snapshot);
      _statusController.add(snapshot.status);

      // When customer answers (Accepted), driver initiates WebRTC offer!
      if (snapshot.status == VoiceCallStatus.accepted) {
        unawaited(_triggerWebRtcOffer(snapshot.callId));
      }

      // Terminal cleanup
      if (snapshot.status.isTerminal) {
        unawaited(cleanupCall());
      }
    } catch (e) {
      developer.log('[CallingRepo] Error parsing envelope payload: $e');
    }
  }

  Future<void> _triggerWebRtcOffer(String callId) async {
    try {
      List<IceServerConfigEntity> servers = _cachedIceServers ?? [];
      if (servers.isEmpty) {
        final iceResult = await getIceServers(callId);
        if (iceResult is ApiSuccessResult<List<IceServerConfigEntity>>) {
          servers = iceResult.data;
          _cachedIceServers = servers;
        }
      }

      await webrtcManager.startOfferSession(
        callId: callId,
        iceServers: servers,
        generation: 0,
      );
    } catch (e) {
      developer.log('[CallingRepo] Error starting WebRTC offer: $e');
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
      final response = await remoteDataSource.initiateCall(request);
      final snapshot = CallingDtoMapper.toSnapshotEntity(response);

      _activeCallId = snapshot.callId;
      _currentSnapshot = snapshot;
      _cachedIceServers = null;

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
      await remoteDataSource.cancelCall(callId);
      await cleanupCall();
    });
  }

  @override
  Future<ApiResult<void>> endCall(String callId) async {
    return safeApiCall(() async {
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
      final response = await remoteDataSource.getIceServers(callId);
      final servers = (response.iceServers ?? const [])
          .map(CallingDtoMapper.toIceServerEntity)
          .toList();
      _cachedIceServers = servers;
      return servers;
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
    await callKitCoordinator.endCall(_activeCallId);
    await webrtcManager.cleanup();
    signalRClient.resetSequenceAndDedupe();
    _activeCallId = null;
    _cachedIceServers = null;
  }
}

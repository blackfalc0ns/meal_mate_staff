import '../../../../../core/network/api_results.dart';
import '../entities/delivery_contact_case_entity.dart';
import '../entities/ice_server_config_entity.dart';
import '../entities/phone_grant_entity.dart';
import '../entities/voice_call_display_entity.dart';
import '../entities/voice_call_eligibility_entity.dart';
import '../entities/voice_call_snapshot_entity.dart';
import '../entities/voice_call_status.dart';
import '../entities/voice_device_session_entity.dart';

abstract class DriverCallingRepository {
  Future<ApiResult<VoiceDeviceSessionEntity>> registerVoiceDevice({
    required String fcmDeviceTokenId,
    required String platform,
    required String deviceId,
    int capabilityVersion = 2,
  });

  Future<ApiResult<void>> revokeVoiceDevice();

  Future<ApiResult<VoiceCallEligibilityEntity>> checkEligibility(
    String tripStopId,
  );

  Future<ApiResult<VoiceCallSnapshotEntity>> initiateCall({
    required String tripStopId,
    required String clientRequestId,
  });

  Future<ApiResult<void>> cancelCall(String callId);

  Future<ApiResult<void>> endCall(String callId);

  Future<ApiResult<VoiceCallSnapshotEntity?>> getActiveCall();

  Future<ApiResult<VoiceCallSnapshotEntity>> getCallSnapshot(String callId);

  Future<ApiResult<List<IceServerConfigEntity>>> getIceServers(String callId);

  Future<ApiResult<void>> reportConnecting(String callId);

  Future<ApiResult<void>> reportConnected(String callId);

  Future<ApiResult<void>> sendHeartbeat(String callId);

  Future<ApiResult<DeliveryContactCaseEntity>> getContactCase(
    String tripStopId,
  );

  Future<ApiResult<DeliveryContactCaseEntity>> holdContactCase({
    required String tripStopId,
    required String notes,
    required String firstAttemptCallId,
  });

  Future<ApiResult<DeliveryContactCaseEntity>> resumeContactCase({
    required String tripStopId,
    double? lat,
    double? lng,
  });

  Future<ApiResult<PhoneGrantEntity>> revealPhone({
    required String tripStopId,
    required String clientRequestId,
    required String reason,
  });

  Future<ApiResult<VoiceCallDisplayEntity>> getCallDisplay(
    String callId, {
    String? languageCode,
  });

  Stream<VoiceCallSnapshotEntity> get onSnapshotUpdated;

  Stream<VoiceCallStatus> get onStatusChanged;

  Future<void> connectSignalR();

  Future<void> disconnectSignalR();

  Future<void> startWebRtcCall({
    required String callId,
    required List<IceServerConfigEntity> iceServers,
  });

  Future<void> toggleMute(bool muted);

  Future<void> toggleSpeaker(bool enabled);

  Future<void> cleanupCall();
}

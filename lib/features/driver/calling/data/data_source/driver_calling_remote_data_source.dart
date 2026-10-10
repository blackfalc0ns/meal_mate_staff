import '../models/request/delivery_contact_hold_request_dto.dart';
import '../models/request/delivery_contact_resume_request_dto.dart';
import '../models/request/delivery_contact_reveal_phone_request_dto.dart';
import '../models/request/voice_call_initiate_request_dto.dart';
import '../models/request/voice_device_register_request_dto.dart';
import '../models/response/delivery_contact_case_response_dto.dart';
import '../models/response/ice_servers_response_dto.dart';
import '../models/response/phone_grant_response_dto.dart';
import '../models/response/voice_call_display_response_dto.dart';
import '../models/response/voice_call_eligibility_response_dto.dart';
import '../models/response/voice_call_snapshot_response_dto.dart';
import '../models/response/voice_device_register_response_dto.dart';

abstract class DriverCallingRemoteDataSource {
  Future<VoiceDeviceRegisterResponseDto> registerDevice(
    VoiceDeviceRegisterRequestDto request,
  );

  Future<void> revokeDevice(String deviceSessionId);

  Future<VoiceCallEligibilityResponseDto> checkEligibility(String tripStopId);

  Future<VoiceCallSnapshotResponseDto> initiateCall(
    VoiceCallInitiateRequestDto request,
  );

  Future<void> cancelCall(String callId);

  Future<void> endCall(String callId);

  Future<VoiceCallSnapshotResponseDto?> getActiveCall();

  Future<VoiceCallSnapshotResponseDto> getCallSnapshot(String callId);

  Future<IceServersResponseDto> getIceServers(String callId);

  Future<void> reportConnecting(String callId);

  Future<void> reportConnected(String callId);

  Future<void> sendHeartbeat(String callId);

  Future<DeliveryContactCaseResponseDto> getContactCase(String tripStopId);

  Future<DeliveryContactCaseResponseDto> holdContactCase(
    String tripStopId,
    DeliveryContactHoldRequestDto request,
  );

  Future<DeliveryContactCaseResponseDto> resumeContactCase(
    String tripStopId,
    DeliveryContactResumeRequestDto request,
  );

  Future<PhoneGrantResponseDto> revealPhone(
    String tripStopId,
    DeliveryContactRevealPhoneRequestDto request,
  );

  Future<VoiceCallDisplayResponseDto> getCallDisplay(
    String callId, {
    String? languageCode,
  });
}

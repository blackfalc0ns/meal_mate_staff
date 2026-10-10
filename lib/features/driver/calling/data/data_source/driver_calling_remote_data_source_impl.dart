import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../../../../../core/services/voice_device_session_storage.dart';
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
import 'driver_calling_remote_data_source.dart';

@Injectable(as: DriverCallingRemoteDataSource)
class DriverCallingRemoteDataSourceImpl implements DriverCallingRemoteDataSource {
  DriverCallingRemoteDataSourceImpl(
    this._apiServices,
    this._sessionStorage,
  );

  final ApiServices _apiServices;
  final VoiceDeviceSessionStorage _sessionStorage;

  String? get _sessionId => _sessionStorage.getDeviceSessionId();

  Future<String?> get _proof => _sessionStorage.getControlProof();

  @override
  Future<VoiceDeviceRegisterResponseDto> registerDevice(
    VoiceDeviceRegisterRequestDto request,
  ) {
    return _apiServices.registerVoiceDevice(request);
  }

  @override
  Future<void> revokeDevice(String deviceSessionId) async {
    final proof = await _proof;
    return _apiServices.revokeVoiceDevice(
      deviceSessionId,
      _sessionId,
      proof,
    );
  }

  @override
  Future<VoiceCallEligibilityResponseDto> checkEligibility(
    String tripStopId,
  ) async {
    final proof = await _proof;
    return _apiServices.checkVoiceCallEligibility(
      tripStopId,
      _sessionId,
      proof,
    );
  }

  @override
  Future<VoiceCallSnapshotResponseDto> initiateCall(
    VoiceCallInitiateRequestDto request,
  ) async {
    final proof = await _proof;
    return _apiServices.initiateVoiceCall(
      request,
      _sessionId,
      proof,
    );
  }

  @override
  Future<void> cancelCall(String callId) async {
    final proof = await _proof;
    return _apiServices.cancelVoiceCall(
      callId,
      _sessionId,
      proof,
    );
  }

  @override
  Future<void> endCall(String callId) async {
    final proof = await _proof;
    return _apiServices.endVoiceCall(
      callId,
      _sessionId,
      proof,
    );
  }

  @override
  Future<VoiceCallSnapshotResponseDto?> getActiveCall() async {
    final proof = await _proof;
    return _apiServices.getActiveVoiceCall(
      _sessionId,
      proof,
    );
  }

  @override
  Future<VoiceCallSnapshotResponseDto> getCallSnapshot(String callId) async {
    final proof = await _proof;
    return _apiServices.getVoiceCallSnapshot(
      callId,
      _sessionId,
      proof,
    );
  }

  @override
  Future<IceServersResponseDto> getIceServers(String callId) async {
    final proof = await _proof;
    return _apiServices.getVoiceIceServers(
      callId,
      _sessionId,
      proof,
    );
  }

  @override
  Future<void> reportConnecting(String callId) async {
    final proof = await _proof;
    return _apiServices.reportVoiceConnecting(
      callId,
      _sessionId,
      proof,
    );
  }

  @override
  Future<void> reportConnected(String callId) async {
    final proof = await _proof;
    return _apiServices.reportVoiceConnected(
      callId,
      _sessionId,
      proof,
    );
  }

  @override
  Future<void> sendHeartbeat(String callId) async {
    final proof = await _proof;
    return _apiServices.sendVoiceHeartbeat(
      callId,
      _sessionId,
      proof,
    );
  }

  @override
  Future<VoiceCallDisplayResponseDto> getCallDisplay(
    String callId, {
    String? languageCode,
  }) {
    return _apiServices.getVoiceCallDisplay(
      callId,
      languageCode,
    );
  }

  @override
  Future<DeliveryContactCaseResponseDto> getContactCase(
    String tripStopId,
  ) async {
    final proof = await _proof;
    return _apiServices.getDeliveryContactCase(
      tripStopId,
      _sessionId,
      proof,
    );
  }

  @override
  Future<DeliveryContactCaseResponseDto> holdContactCase(
    String tripStopId,
    DeliveryContactHoldRequestDto request,
  ) async {
    final proof = await _proof;
    return _apiServices.holdDeliveryContactCase(
      tripStopId,
      request,
      _sessionId,
      proof,
    );
  }

  @override
  Future<DeliveryContactCaseResponseDto> resumeContactCase(
    String tripStopId,
    DeliveryContactResumeRequestDto request,
  ) async {
    final proof = await _proof;
    return _apiServices.resumeDeliveryContactCase(
      tripStopId,
      request,
      _sessionId,
      proof,
    );
  }

  @override
  Future<PhoneGrantResponseDto> revealPhone(
    String tripStopId,
    DeliveryContactRevealPhoneRequestDto request,
  ) async {
    final proof = await _proof;
    return _apiServices.revealDeliveryCustomerPhone(
      tripStopId,
      request,
      'no-store',
      _sessionId,
      proof,
    );
  }
}

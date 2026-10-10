import '../../domain/entities/delivery_contact_case_entity.dart';
import '../../domain/entities/ice_server_config_entity.dart';
import '../../domain/entities/phone_grant_entity.dart';
import '../../domain/entities/voice_call_display_entity.dart';
import '../../domain/entities/voice_call_eligibility_entity.dart';
import '../../domain/entities/voice_call_snapshot_entity.dart';
import '../../domain/entities/voice_call_status.dart';
import '../../domain/entities/voice_device_session_entity.dart';
import '../models/response/delivery_contact_case_response_dto.dart';
import '../models/response/ice_servers_response_dto.dart';
import '../models/response/phone_grant_response_dto.dart';
import '../models/response/voice_call_display_response_dto.dart';
import '../models/response/voice_call_eligibility_response_dto.dart';
import '../models/response/voice_call_snapshot_response_dto.dart';
import '../models/response/voice_device_register_response_dto.dart';

class CallingDtoMapper {
  static VoiceCallSnapshotEntity toSnapshotEntity(
    VoiceCallSnapshotResponseDto dto,
  ) {
    return VoiceCallSnapshotEntity(
      callId: dto.callId ?? '',
      tripStopId: dto.tripStopId ?? '',
      protocolVersion: dto.protocolVersion ?? 2,
      sequence: dto.sequence ?? 0,
      status: VoiceCallStatus.fromString(dto.status),
      endReason: dto.endReason,
      startedAtUtc: _parseDateTime(dto.startedAtUtc),
      acceptedAtUtc: _parseDateTime(dto.acceptedAtUtc),
      connectedAtUtc: _parseDateTime(dto.connectedAtUtc),
      endedAtUtc: _parseDateTime(dto.endedAtUtc),
      durationSeconds: dto.durationSeconds,
      deadlineAtUtc: _parseDateTime(dto.deadlineAtUtc),
      winningDeviceSessionId: dto.winningDeviceSessionId,
      localParticipantRole: dto.localParticipantRole ?? 'Driver',
    );
  }

  static VoiceCallEligibilityEntity toEligibilityEntity(
    VoiceCallEligibilityResponseDto dto,
  ) {
    return VoiceCallEligibilityEntity(
      canInitiate: dto.canInitiate ?? false,
      reasonCode: dto.reasonCode ?? '',
      distanceMeters: dto.distanceMeters,
      locationAgeSeconds: dto.locationAgeSeconds,
      canHold: dto.canHold ?? false,
      canRetry: dto.canRetry ?? false,
      canRevealPhone: dto.canRevealPhone ?? false,
      contactCaseId: dto.contactCaseId,
    );
  }

  static DeliveryContactCaseEntity toContactCaseEntity(
    DeliveryContactCaseResponseDto dto,
  ) {
    return DeliveryContactCaseEntity(
      contactCaseId: dto.contactCaseId ?? '',
      tripStopId: dto.tripStopId ?? '',
      status: dto.status ?? 'Open',
      attemptCount: dto.attemptCount ?? 0,
      firstAttemptCallId: dto.firstAttemptCallId,
      lastAttemptCallId: dto.lastAttemptCallId,
      canHold: dto.canHold ?? false,
      canResume: dto.canResume ?? false,
      canRevealPhone: dto.canRevealPhone ?? false,
      resumeCooldownRemainingSeconds:
          dto.resumeCooldownRemainingSeconds ?? 0,
      customerPhoneMasked: dto.customerPhoneMasked,
    );
  }

  static PhoneGrantEntity toPhoneGrantEntity(PhoneGrantResponseDto dto) {
    return PhoneGrantEntity(
      grantId: dto.grantId ?? '',
      expiresAtUtc: _parseDateTime(dto.expiresAtUtc) ??
          DateTime.now().toUtc().add(const Duration(minutes: 5)),
      customerPhone: dto.customerPhone ?? '',
      contactCaseId: dto.contactCaseId ?? '',
    );
  }

  static IceServerConfigEntity toIceServerEntity(IceServerDto dto) {
    return IceServerConfigEntity(
      urls: dto.urls ?? const [],
      username: dto.username,
      credential: dto.credential,
    );
  }

  static VoiceDeviceSessionEntity toDeviceSessionEntity(
    VoiceDeviceRegisterResponseDto dto,
  ) {
    return VoiceDeviceSessionEntity(
      deviceSessionId: dto.deviceSessionId,
      controlProof: dto.controlProof,
      expiresAtUtc: _parseDateTime(dto.expiresAtUtc) ??
          DateTime.now().toUtc().add(const Duration(hours: 24)),
    );
  }

  static VoiceCallDisplayEntity toDisplayEntity(
    VoiceCallDisplayResponseDto dto,
  ) {
    return VoiceCallDisplayEntity(
      callId: dto.callId ?? '',
      tripStopId: dto.tripStopId,
      driverName: dto.driverName,
      driverImageUrl: dto.driverImageUrl,
      driverRole: dto.driverRole,
      vehicleType: dto.vehicleType,
      plateNumber: dto.plateNumber,
      deliveryAddress: dto.deliveryAddress,
      deliveryZone: dto.deliveryZone,
      orderCode: dto.orderCode,
      mealSummary: dto.mealSummary,
      slotLabel: dto.slotLabel,
      boxCount: dto.boxCount,
      stopStatus: dto.stopStatus,
    );
  }

  static DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }
}

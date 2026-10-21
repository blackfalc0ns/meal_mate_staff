import '../../domain/entities/driver_reassignment_details_entity.dart';
import '../../domain/entities/reassignment_reason.dart';
import '../../domain/entities/reassignment_request_entity.dart';
import '../../domain/entities/reassignment_result_entity.dart';
import '../models/request/driver_reassignment_request_dto.dart';
import '../models/response/driver_reassignment_request_details_dto.dart';
import '../models/response/driver_reassignment_response_dto.dart';

extension ReassignmentReasonMapper on ReassignmentReason {
  String toWire() => switch (this) {
        ReassignmentReason.vehicleBreakdown => 'VehicleBreakdown',
        ReassignmentReason.trafficAccident => 'TrafficAccident',
        ReassignmentReason.medicalOrPersonalEmergency =>
          'MedicalOrPersonalEmergency',
        ReassignmentReason.deviceFailure => 'DeviceFailure',
        ReassignmentReason.otherOperationalReason => 'OtherOperationalReason',
      };

  static ReassignmentReason fromWire(String? value) => switch (value?.trim()) {
        'VehicleBreakdown' => ReassignmentReason.vehicleBreakdown,
        'TrafficAccident' => ReassignmentReason.trafficAccident,
        'MedicalOrPersonalEmergency' =>
          ReassignmentReason.medicalOrPersonalEmergency,
        'DeviceFailure' => ReassignmentReason.deviceFailure,
        'OtherOperationalReason' => ReassignmentReason.otherOperationalReason,
        _ => throw FormatException('Unknown wire reason: $value'),
      };
}

extension ReassignmentRequestEntityMapper on ReassignmentRequestEntity {
  DriverReassignmentRequestDto toDto() {
    final trimmedNotes = notes.trim();
    final cleanNotes = trimmedNotes.isNotEmpty ? trimmedNotes : null;

    final lat = latitude;
    final lng = longitude;
    final hasValidCoordinates = lat != null &&
        lng != null &&
        lat.isFinite &&
        lng.isFinite &&
        lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;

    return DriverReassignmentRequestDto(
      reason: reason.toWire(),
      notes: cleanNotes,
      latitude: hasValidCoordinates ? lat : null,
      longitude: hasValidCoordinates ? lng : null,
    );
  }
}

extension DriverReassignmentResponseDtoMapper on DriverReassignmentResponseDto {
  ReassignmentResultEntity toEntity({required String targetBoxId}) {
    final cleanRequestId = requestId?.trim();
    if (cleanRequestId == null || cleanRequestId.isEmpty) {
      throw const FormatException('Invalid or missing requestId');
    }

    final cleanStatus = status?.trim();
    if (cleanStatus == null || cleanStatus.isEmpty) {
      throw const FormatException('Invalid or missing status');
    }

    final cleanBoxId = boxId?.trim();
    if (cleanBoxId != null &&
        cleanBoxId.isNotEmpty &&
        targetBoxId.trim().isNotEmpty &&
        cleanBoxId != targetBoxId.trim()) {
      throw const FormatException('Mismatched target boxId in response');
    }

    final resolvedBoxId = (cleanBoxId != null && cleanBoxId.isNotEmpty)
        ? cleanBoxId
        : targetBoxId.trim();

    DateTime? parsedDate;
    if (requestedAtUtc != null && requestedAtUtc!.trim().isNotEmpty) {
      parsedDate = DateTime.tryParse(requestedAtUtc!.trim())?.toUtc();
    }

    return ReassignmentResultEntity(
      requestId: cleanRequestId,
      boxId: resolvedBoxId,
      boxCode: boxCode?.trim(),
      status: cleanStatus,
      message: message?.trim(),
      requestedAtUtc: parsedDate,
    );
  }
}

extension DriverReassignmentDetailsDtoMapper
    on DriverReassignmentRequestDetailsDto {
  DriverReassignmentDetailsEntity toEntity() {
    DateTime? parsedRequestedAt;
    if (requestedAtUtc != null && requestedAtUtc!.trim().isNotEmpty) {
      parsedRequestedAt = DateTime.tryParse(requestedAtUtc!.trim())?.toUtc();
    }
    DateTime? parsedDecidedAt;
    if (decidedAtUtc != null && decidedAtUtc!.trim().isNotEmpty) {
      parsedDecidedAt = DateTime.tryParse(decidedAtUtc!.trim())?.toUtc();
    }

    return DriverReassignmentDetailsEntity(
      requestId: requestId ?? '',
      boxId: boxId,
      boxCode: boxCode,
      status: status ?? 'ReassignmentRequested',
      reason: reason,
      notes: notes,
      requestedAtUtc: parsedRequestedAt,
      decision: decision,
      decisionNotes: decisionNotes,
      decidedByUserId: decidedByUserId,
      decidedAtUtc: parsedDecidedAt,
      handoverId: handoverId,
      handoverStatus: handoverStatus,
      replacementDriverId: replacementDriverId,
      replacementTripId: replacementTripId,
      latitude: latitude,
      longitude: longitude,
      message: message,
    );
  }
}

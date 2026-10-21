import 'package:json_annotation/json_annotation.dart';

part 'driver_reassignment_request_details_dto.g.dart';

@JsonSerializable()
class DriverReassignmentRequestDetailsDto {
  const DriverReassignmentRequestDetailsDto({
    this.requestId,
    this.boxId,
    this.boxCode,
    this.status,
    this.reason,
    this.notes,
    this.requestedAtUtc,
    this.decision,
    this.decisionNotes,
    this.decidedByUserId,
    this.decidedAtUtc,
    this.handoverId,
    this.handoverStatus,
    this.replacementDriverId,
    this.replacementTripId,
    this.latitude,
    this.longitude,
    this.message,
  });

  factory DriverReassignmentRequestDetailsDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverReassignmentRequestDetailsDtoFromJson(json);

  final String? requestId;
  final String? boxId;
  final String? boxCode;
  final String? status;
  final String? reason;
  final String? notes;
  final String? requestedAtUtc;
  final String? decision;
  final String? decisionNotes;
  final String? decidedByUserId;
  final String? decidedAtUtc;
  final String? handoverId;
  final String? handoverStatus;
  final String? replacementDriverId;
  final String? replacementTripId;
  final double? latitude;
  final double? longitude;
  final String? message;

  Map<String, dynamic> toJson() =>
      _$DriverReassignmentRequestDetailsDtoToJson(this);
}

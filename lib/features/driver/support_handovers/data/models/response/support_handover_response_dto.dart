import 'package:json_annotation/json_annotation.dart';

import 'support_handover_box_dto.dart';

part 'support_handover_response_dto.g.dart';

@JsonSerializable()
class SupportHandoverResponseDto {
  const SupportHandoverResponseDto({
    this.handoverId,
    this.issueId,
    this.tripId,
    this.originalDriverId,
    this.replacementDriverId,
    this.restaurantId,
    this.status,
    this.pickupLatitude,
    this.pickupLongitude,
    this.assignedAtUtc,
    this.arrivedAtUtc,
    this.completedAtUtc,
    this.replacementTripId,
    this.receivedCount,
    this.missingCount,
    this.damagedCount,
    this.pendingCount,
    this.pickupLocationSource,
    this.pickupLocationRecordedAtUtc,
    this.issueTitle,
    this.issueCategory,
    this.issueDescription,
    this.tripCode,
    this.originalDriverName,
    this.originalDriverPhone,
    this.replacementDriverName,
    this.replacementDriverPhone,
    this.boxes,
  });

  factory SupportHandoverResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SupportHandoverResponseDtoFromJson(json);

  final String? handoverId;
  final String? issueId;
  final String? tripId;
  final String? originalDriverId;
  final String? replacementDriverId;
  final String? restaurantId;
  final String? status;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String? assignedAtUtc;
  final String? arrivedAtUtc;
  final String? completedAtUtc;
  final String? replacementTripId;
  final int? receivedCount;
  final int? missingCount;
  final int? damagedCount;
  final int? pendingCount;
  final String? pickupLocationSource;
  final String? pickupLocationRecordedAtUtc;
  final String? issueTitle;
  final String? issueCategory;
  final String? issueDescription;
  final String? tripCode;
  final String? originalDriverName;
  final String? originalDriverPhone;
  final String? replacementDriverName;
  final String? replacementDriverPhone;
  final List<SupportHandoverBoxDto>? boxes;

  Map<String, dynamic> toJson() => _$SupportHandoverResponseDtoToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'driver_registration_status_response_dto.g.dart';

@JsonSerializable()
class DriverRegistrationStatusResponseDto {
  const DriverRegistrationStatusResponseDto({
    this.registrationId,
    this.phone,
    this.fullName,
    this.restaurantName,
    this.restaurantId,
    this.status,
    this.stage,
    this.badge,
    this.title,
    this.subtitle,
    this.notice,
    this.restaurantApprovalStatus,
    this.adminApprovalStatus,
    this.canResubmit,
    this.isApproved,
    this.changeRequestNotes,
    this.rejectionReason,
  });

  factory DriverRegistrationStatusResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DriverRegistrationStatusResponseDtoFromJson(json);

  final String? registrationId;
  final String? phone;
  final String? fullName;
  final String? restaurantName;
  final String? restaurantId;
  final String? status;
  final int? stage;
  final String? badge;
  final String? title;
  final String? subtitle;
  final String? notice;
  final String? restaurantApprovalStatus;
  final String? adminApprovalStatus;
  final bool? canResubmit;
  final bool? isApproved;
  final String? changeRequestNotes;
  final String? rejectionReason;

  Map<String, dynamic> toJson() =>
      _$DriverRegistrationStatusResponseDtoToJson(this);
}

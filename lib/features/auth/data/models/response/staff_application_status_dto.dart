import 'package:json_annotation/json_annotation.dart';

part 'staff_application_status_dto.g.dart';

@JsonSerializable()
class StaffApplicationStatusDto {
  const StaffApplicationStatusDto({
    this.registrationId,
    this.stage,
    this.badge,
    this.title,
    this.subtitle,
    this.notice,
    this.canResubmit,
    this.isApproved,
    this.restaurantApprovalStatus,
    this.adminApprovalStatus,
    this.changeRequestNotes,
    this.rejectionReason,
  });

  factory StaffApplicationStatusDto.fromJson(Map<String, dynamic> json) =>
      _$StaffApplicationStatusDtoFromJson(json);

  final String? registrationId;
  final int? stage;
  final String? badge;
  final String? title;
  final String? subtitle;
  final String? notice;
  final bool? canResubmit;
  final bool? isApproved;
  final String? restaurantApprovalStatus;
  final String? adminApprovalStatus;
  final String? changeRequestNotes;
  final String? rejectionReason;

  Map<String, dynamic> toJson() => _$StaffApplicationStatusDtoToJson(this);
}

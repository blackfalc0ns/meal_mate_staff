// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_application_status_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffApplicationStatusDto _$StaffApplicationStatusDtoFromJson(
  Map<String, dynamic> json,
) => StaffApplicationStatusDto(
  registrationId: json['registrationId'] as String?,
  stage: (json['stage'] as num?)?.toInt(),
  badge: json['badge'] as String?,
  title: json['title'] as String?,
  subtitle: json['subtitle'] as String?,
  notice: json['notice'] as String?,
  canResubmit: json['canResubmit'] as bool?,
  isApproved: json['isApproved'] as bool?,
  restaurantApprovalStatus: json['restaurantApprovalStatus'] as String?,
  adminApprovalStatus: json['adminApprovalStatus'] as String?,
  changeRequestNotes: json['changeRequestNotes'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
);

Map<String, dynamic> _$StaffApplicationStatusDtoToJson(
  StaffApplicationStatusDto instance,
) => <String, dynamic>{
  'registrationId': instance.registrationId,
  'stage': instance.stage,
  'badge': instance.badge,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'notice': instance.notice,
  'canResubmit': instance.canResubmit,
  'isApproved': instance.isApproved,
  'restaurantApprovalStatus': instance.restaurantApprovalStatus,
  'adminApprovalStatus': instance.adminApprovalStatus,
  'changeRequestNotes': instance.changeRequestNotes,
  'rejectionReason': instance.rejectionReason,
};

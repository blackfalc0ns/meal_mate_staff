// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_registration_status_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverRegistrationStatusResponseDto
_$DriverRegistrationStatusResponseDtoFromJson(Map<String, dynamic> json) =>
    DriverRegistrationStatusResponseDto(
      registrationId: json['registrationId'] as String?,
      phone: json['phone'] as String?,
      fullName: json['fullName'] as String?,
      restaurantName: json['restaurantName'] as String?,
      restaurantId: json['restaurantId'] as String?,
      status: json['status'] as String?,
      stage: (json['stage'] as num?)?.toInt(),
      badge: json['badge'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      notice: json['notice'] as String?,
      restaurantApprovalStatus: json['restaurantApprovalStatus'] as String?,
      adminApprovalStatus: json['adminApprovalStatus'] as String?,
      canResubmit: json['canResubmit'] as bool?,
      isApproved: json['isApproved'] as bool?,
      changeRequestNotes: json['changeRequestNotes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );

Map<String, dynamic> _$DriverRegistrationStatusResponseDtoToJson(
  DriverRegistrationStatusResponseDto instance,
) => <String, dynamic>{
  'registrationId': instance.registrationId,
  'phone': instance.phone,
  'fullName': instance.fullName,
  'restaurantName': instance.restaurantName,
  'restaurantId': instance.restaurantId,
  'status': instance.status,
  'stage': instance.stage,
  'badge': instance.badge,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'notice': instance.notice,
  'restaurantApprovalStatus': instance.restaurantApprovalStatus,
  'adminApprovalStatus': instance.adminApprovalStatus,
  'canResubmit': instance.canResubmit,
  'isApproved': instance.isApproved,
  'changeRequestNotes': instance.changeRequestNotes,
  'rejectionReason': instance.rejectionReason,
};

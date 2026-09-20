// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_lookup_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneLookupResponseDto _$PhoneLookupResponseDtoFromJson(
  Map<String, dynamic> json,
) => PhoneLookupResponseDto(
  exists: json['exists'] as bool?,
  isFirstTimeSetup: json['isFirstTimeSetup'] as bool?,
  role: json['role'] as String?,
  phone: json['phone'] as String?,
  fullName: json['fullName'] as String?,
  restaurantName: json['restaurantName'] as String?,
  restaurantId: json['restaurantId'] as String?,
  status: json['status'] as String?,
  applicationStatus: json['applicationStatus'] == null
      ? null
      : StaffApplicationStatusDto.fromJson(
          json['applicationStatus'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PhoneLookupResponseDtoToJson(
  PhoneLookupResponseDto instance,
) => <String, dynamic>{
  'exists': instance.exists,
  'isFirstTimeSetup': instance.isFirstTimeSetup,
  'role': instance.role,
  'phone': instance.phone,
  'fullName': instance.fullName,
  'restaurantName': instance.restaurantName,
  'restaurantId': instance.restaurantId,
  'status': instance.status,
  'applicationStatus': instance.applicationStatus,
};

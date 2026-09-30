// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_phone_lookup_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverPhoneLookupResponseDto _$DriverPhoneLookupResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverPhoneLookupResponseDto(
  exists: json['exists'] as bool?,
  requiresFirstTimeSetup:
      DriverPhoneLookupResponseDto._readFirstTimeSetup(
            json,
            'requiresFirstTimeSetup',
          )
          as bool?,
  fullName: json['fullName'] as String?,
  restaurantName: json['restaurantName'] as String?,
  accountStatus:
      DriverPhoneLookupResponseDto._readAccountStatus(json, 'accountStatus')
          as String?,
);

Map<String, dynamic> _$DriverPhoneLookupResponseDtoToJson(
  DriverPhoneLookupResponseDto instance,
) => <String, dynamic>{
  'exists': instance.exists,
  'requiresFirstTimeSetup': instance.requiresFirstTimeSetup,
  'fullName': instance.fullName,
  'restaurantName': instance.restaurantName,
  'accountStatus': instance.accountStatus,
};

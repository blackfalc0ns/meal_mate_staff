// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_auth_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverAuthResponseDto _$DriverAuthResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverAuthResponseDto(
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
  tokenType: json['tokenType'] as String?,
  expiresIn: (json['expiresIn'] as num?)?.toInt(),
  userId: json['userId'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  fullName: json['fullName'] as String?,
  userType: json['userType'] as String?,
  accountStatus: json['accountStatus'] as String?,
  restaurantId: json['restaurantId'] as String?,
  roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  permissions: (json['permissions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  nextStep: json['nextStep'] as String?,
);

Map<String, dynamic> _$DriverAuthResponseDtoToJson(
  DriverAuthResponseDto instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'tokenType': instance.tokenType,
  'expiresIn': instance.expiresIn,
  'userId': instance.userId,
  'phoneNumber': instance.phoneNumber,
  'fullName': instance.fullName,
  'userType': instance.userType,
  'accountStatus': instance.accountStatus,
  'restaurantId': instance.restaurantId,
  'roles': instance.roles,
  'permissions': instance.permissions,
  'nextStep': instance.nextStep,
};

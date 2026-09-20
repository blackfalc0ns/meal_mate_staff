// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_auth_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffAuthResponseDto _$StaffAuthResponseDtoFromJson(
  Map<String, dynamic> json,
) => StaffAuthResponseDto(
  userId: json['userId'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  fullName: json['fullName'] as String?,
  userType: json['userType'] as String?,
  accountStatus: json['accountStatus'] as String?,
  restaurantId: json['restaurantId'] as String?,
  roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
  accessTokenExpiresAtUtc: json['accessTokenExpiresAtUtc'] as String?,
  isAuthenticated: json['isAuthenticated'] as bool?,
);

Map<String, dynamic> _$StaffAuthResponseDtoToJson(
  StaffAuthResponseDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'phoneNumber': instance.phoneNumber,
  'fullName': instance.fullName,
  'userType': instance.userType,
  'accountStatus': instance.accountStatus,
  'restaurantId': instance.restaurantId,
  'roles': instance.roles,
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'accessTokenExpiresAtUtc': instance.accessTokenExpiresAtUtc,
  'isAuthenticated': instance.isAuthenticated,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_nationality_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverNationalityResponseDto _$DriverNationalityResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverNationalityResponseDto(
  code: json['code'] as String?,
  name: json['name'] as String?,
  nameAr: json['nameAr'] as String?,
  nameEn: json['nameEn'] as String?,
  countryName: json['countryName'] as String?,
  countryNameAr: json['countryNameAr'] as String?,
  countryNameEn: json['countryNameEn'] as String?,
  flagEmoji: json['flagEmoji'] as String?,
);

Map<String, dynamic> _$DriverNationalityResponseDtoToJson(
  DriverNationalityResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
  'countryName': instance.countryName,
  'countryNameAr': instance.countryNameAr,
  'countryNameEn': instance.countryNameEn,
  'flagEmoji': instance.flagEmoji,
};

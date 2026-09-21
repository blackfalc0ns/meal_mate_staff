// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_vehicle_type_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverVehicleTypeResponseDto _$DriverVehicleTypeResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverVehicleTypeResponseDto(
  code: json['code'] as String?,
  nameAr: json['nameAr'] as String?,
  nameEn: json['nameEn'] as String?,
  iconKey: json['iconKey'] as String?,
);

Map<String, dynamic> _$DriverVehicleTypeResponseDtoToJson(
  DriverVehicleTypeResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
  'iconKey': instance.iconKey,
};

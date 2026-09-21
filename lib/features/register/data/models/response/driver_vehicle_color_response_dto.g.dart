// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_vehicle_color_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverVehicleColorResponseDto _$DriverVehicleColorResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverVehicleColorResponseDto(
  hex: json['hex'] as String?,
  nameAr: json['nameAr'] as String?,
  nameEn: json['nameEn'] as String?,
  isDefault: json['isDefault'] as bool?,
  displayOrder: (json['displayOrder'] as num?)?.toInt(),
);

Map<String, dynamic> _$DriverVehicleColorResponseDtoToJson(
  DriverVehicleColorResponseDto instance,
) => <String, dynamic>{
  'hex': instance.hex,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
  'isDefault': instance.isDefault,
  'displayOrder': instance.displayOrder,
};

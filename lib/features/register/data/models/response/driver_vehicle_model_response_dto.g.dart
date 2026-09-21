// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_vehicle_model_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverVehicleModelResponseDto _$DriverVehicleModelResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverVehicleModelResponseDto(
  value: json['value'] as String?,
  makeCode: json['makeCode'] as String?,
  makeNameAr: json['makeNameAr'] as String?,
  makeNameEn: json['makeNameEn'] as String?,
  modelCode: json['modelCode'] as String?,
  modelNameAr: json['modelNameAr'] as String?,
  modelNameEn: json['modelNameEn'] as String?,
  fullNameAr: json['fullNameAr'] as String?,
  fullNameEn: json['fullNameEn'] as String?,
  vehicleType: json['vehicleType'] as String?,
);

Map<String, dynamic> _$DriverVehicleModelResponseDtoToJson(
  DriverVehicleModelResponseDto instance,
) => <String, dynamic>{
  'value': instance.value,
  'makeCode': instance.makeCode,
  'makeNameAr': instance.makeNameAr,
  'makeNameEn': instance.makeNameEn,
  'modelCode': instance.modelCode,
  'modelNameAr': instance.modelNameAr,
  'modelNameEn': instance.modelNameEn,
  'fullNameAr': instance.fullNameAr,
  'fullNameEn': instance.fullNameEn,
  'vehicleType': instance.vehicleType,
};

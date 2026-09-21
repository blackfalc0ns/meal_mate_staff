import 'package:json_annotation/json_annotation.dart';

part 'driver_vehicle_type_response_dto.g.dart';

@JsonSerializable()
class DriverVehicleTypeResponseDto {
  const DriverVehicleTypeResponseDto({
    this.code,
    this.nameAr,
    this.nameEn,
    this.iconKey,
  });

  factory DriverVehicleTypeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverVehicleTypeResponseDtoFromJson(json);

  final String? code;
  final String? nameAr;
  final String? nameEn;
  final String? iconKey;

  Map<String, dynamic> toJson() => _$DriverVehicleTypeResponseDtoToJson(this);
}

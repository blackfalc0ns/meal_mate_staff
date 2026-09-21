import 'package:json_annotation/json_annotation.dart';

part 'driver_vehicle_model_response_dto.g.dart';

@JsonSerializable()
class DriverVehicleModelResponseDto {
  const DriverVehicleModelResponseDto({
    this.value,
    this.makeCode,
    this.makeNameAr,
    this.makeNameEn,
    this.modelCode,
    this.modelNameAr,
    this.modelNameEn,
    this.fullNameAr,
    this.fullNameEn,
    this.vehicleType,
  });

  factory DriverVehicleModelResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverVehicleModelResponseDtoFromJson(json);

  final String? value;
  final String? makeCode;
  final String? makeNameAr;
  final String? makeNameEn;
  final String? modelCode;
  final String? modelNameAr;
  final String? modelNameEn;
  final String? fullNameAr;
  final String? fullNameEn;
  final String? vehicleType;

  Map<String, dynamic> toJson() => _$DriverVehicleModelResponseDtoToJson(this);
}

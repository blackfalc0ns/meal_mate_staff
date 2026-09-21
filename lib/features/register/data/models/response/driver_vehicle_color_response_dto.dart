import 'package:json_annotation/json_annotation.dart';

part 'driver_vehicle_color_response_dto.g.dart';

@JsonSerializable()
class DriverVehicleColorResponseDto {
  const DriverVehicleColorResponseDto({
    this.hex,
    this.nameAr,
    this.nameEn,
    this.isDefault,
    this.displayOrder,
  });

  factory DriverVehicleColorResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverVehicleColorResponseDtoFromJson(json);

  final String? hex;
  final String? nameAr;
  final String? nameEn;
  final bool? isDefault;
  final int? displayOrder;

  Map<String, dynamic> toJson() => _$DriverVehicleColorResponseDtoToJson(this);
}

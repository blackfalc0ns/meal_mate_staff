import 'package:json_annotation/json_annotation.dart';

part 'driver_start_delivery_customer_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class DriverStartDeliveryCustomerDto {
  const DriverStartDeliveryCustomerDto({
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.notes,
  });

  factory DriverStartDeliveryCustomerDto.fromJson(Map<String, dynamic> json) =>
      _$DriverStartDeliveryCustomerDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DriverStartDeliveryCustomerDtoToJson(this);

  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? notes;
}

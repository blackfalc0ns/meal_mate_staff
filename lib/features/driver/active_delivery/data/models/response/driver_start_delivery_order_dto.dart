import 'package:json_annotation/json_annotation.dart';

part 'driver_start_delivery_order_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class DriverStartDeliveryOrderDto {
  const DriverStartDeliveryOrderDto({
    this.code,
    this.boxCount,
    this.deliveryTimeSlot,
  });

  factory DriverStartDeliveryOrderDto.fromJson(Map<String, dynamic> json) =>
      _$DriverStartDeliveryOrderDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DriverStartDeliveryOrderDtoToJson(this);

  final String? code;
  final int? boxCount;
  final String? deliveryTimeSlot;
}

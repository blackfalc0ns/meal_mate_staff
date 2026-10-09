import 'package:json_annotation/json_annotation.dart';
import 'driver_start_delivery_customer_dto.dart';
import 'driver_start_delivery_order_dto.dart';
import 'driver_start_delivery_navigation_dto.dart';

part 'driver_start_delivery_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class DriverStartDeliveryResponseDto {
  const DriverStartDeliveryResponseDto({
    this.boxId,
    this.tripId,
    this.status,
    this.startedAtUtc,
    this.customer,
    this.order,
    this.navigation,
  });

  factory DriverStartDeliveryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverStartDeliveryResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DriverStartDeliveryResponseDtoToJson(this);

  final String? boxId;
  final String? tripId;
  final String? status;
  final String? startedAtUtc;
  final DriverStartDeliveryCustomerDto? customer;
  final DriverStartDeliveryOrderDto? order;
  final DriverStartDeliveryNavigationDto? navigation;
}

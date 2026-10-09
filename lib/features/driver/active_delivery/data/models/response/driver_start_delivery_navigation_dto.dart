import 'package:json_annotation/json_annotation.dart';

part 'driver_start_delivery_navigation_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class DriverStartDeliveryNavigationDto {
  const DriverStartDeliveryNavigationDto({this.url});

  factory DriverStartDeliveryNavigationDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverStartDeliveryNavigationDtoFromJson(json);
  Map<String, dynamic> toJson() =>
      _$DriverStartDeliveryNavigationDtoToJson(this);

  final String? url;
}

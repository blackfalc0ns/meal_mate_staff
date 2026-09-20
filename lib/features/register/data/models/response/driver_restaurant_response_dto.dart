import 'package:json_annotation/json_annotation.dart';

part 'driver_restaurant_response_dto.g.dart';

@JsonSerializable()
class DriverRestaurantResponseDto {
  const DriverRestaurantResponseDto({
    this.id,
    this.tradeName,
    this.tradeNameAr,
    this.tradeNameEn,
    this.logoUrl,
    this.contactPhone,
  });

  factory DriverRestaurantResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverRestaurantResponseDtoFromJson(json);

  final String? id;
  final String? tradeName;
  final String? tradeNameAr;
  final String? tradeNameEn;
  final String? logoUrl;
  final String? contactPhone;

  Map<String, dynamic> toJson() => _$DriverRestaurantResponseDtoToJson(this);
}

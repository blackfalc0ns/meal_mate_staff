// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_restaurant_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverRestaurantResponseDto _$DriverRestaurantResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverRestaurantResponseDto(
  id: json['id'] as String?,
  tradeName: json['tradeName'] as String?,
  tradeNameAr: json['tradeNameAr'] as String?,
  tradeNameEn: json['tradeNameEn'] as String?,
  logoUrl: json['logoUrl'] as String?,
  contactPhone: json['contactPhone'] as String?,
);

Map<String, dynamic> _$DriverRestaurantResponseDtoToJson(
  DriverRestaurantResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'tradeName': instance.tradeName,
  'tradeNameAr': instance.tradeNameAr,
  'tradeNameEn': instance.tradeNameEn,
  'logoUrl': instance.logoUrl,
  'contactPhone': instance.contactPhone,
};

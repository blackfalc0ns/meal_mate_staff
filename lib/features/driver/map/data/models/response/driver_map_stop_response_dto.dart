import 'package:json_annotation/json_annotation.dart';

part 'driver_map_stop_response_dto.g.dart';

@JsonSerializable()
class DriverMapStopResponseDto {
  const DriverMapStopResponseDto({
    this.stopId,
    this.sequenceBadge,
    this.sequenceNumber,
    this.boxCode,
    this.customerName,
    this.customerPhone,
    this.addressShort,
    this.fullAddress,
    this.mealsCount,
    this.mealsSummary,
    this.deliveryTimeSlot,
    this.status,
    this.statusText,
    this.statusColor,
    this.isCurrent,
    this.latitude,
    this.longitude,
  });

  factory DriverMapStopResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverMapStopResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverMapStopResponseDtoToJson(this);

  final String? stopId;
  final String? sequenceBadge;
  final int? sequenceNumber;
  final String? boxCode;
  final String? customerName;
  final String? customerPhone;
  final String? addressShort;
  final String? fullAddress;
  final int? mealsCount;
  final String? mealsSummary;
  final String? deliveryTimeSlot;
  final String? status;
  final String? statusText;
  final String? statusColor;
  final bool? isCurrent;
  final double? latitude;
  final double? longitude;
}

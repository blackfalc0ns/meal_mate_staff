import 'package:json_annotation/json_annotation.dart';

part 'driver_delivery_manifest_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverDeliveryManifestResponseDto {
  const DriverDeliveryManifestResponseDto({
    this.tripId,
    this.tripCode,
    this.tripStatus,
    this.tripStatusText,
    this.serverTimeUtc,
    this.counts,
    this.stops,
  });

  factory DriverDeliveryManifestResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DriverDeliveryManifestResponseDtoFromJson(json);

  final String? tripId;
  final String? tripCode;
  final String? tripStatus;
  final String? tripStatusText;
  final String? serverTimeUtc;
  final DriverDeliveryCountsResponseDto? counts;
  final List<DriverDeliveryStopResponseDto>? stops;
}

@JsonSerializable(createToJson: false)
class DriverDeliveryCountsResponseDto {
  const DriverDeliveryCountsResponseDto({
    this.total,
    this.inProgress,
    this.delivered,
    this.failed,
  });

  factory DriverDeliveryCountsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverDeliveryCountsResponseDtoFromJson(json);

  final int? total;
  final int? inProgress;
  final int? delivered;
  final int? failed;
}

@JsonSerializable(createToJson: false)
class DriverDeliveryStopResponseDto {
  const DriverDeliveryStopResponseDto({
    this.tripStopId,
    this.boxId,
    this.boxCode,
    this.sequenceNumber,
    this.customerName,
    this.deliveryZone,
    this.formattedAddress,
    this.latitude,
    this.longitude,
    this.mealsCount,
    this.mealsSummary,
    this.deliveryTimeSlot,
    this.status,
    this.statusText,
    this.deliveredAtUtc,
    this.failureReasonCategory,
    this.failureReasonText,
    this.isCurrentStop,
    this.canCompleteDelivery,
    this.canNavigate,
    this.canCallCustomer,
    this.maskedPhoneNumber,
  });

  factory DriverDeliveryStopResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverDeliveryStopResponseDtoFromJson(json);

  final String? tripStopId;
  final String? boxId;
  final String? boxCode;
  final int? sequenceNumber;
  final String? customerName;
  final String? deliveryZone;
  final String? formattedAddress;
  final num? latitude;
  final num? longitude;
  final int? mealsCount;
  final String? mealsSummary;
  final String? deliveryTimeSlot;
  final String? status;
  final String? statusText;
  final String? deliveredAtUtc;
  final String? failureReasonCategory;
  final String? failureReasonText;
  final bool? isCurrentStop;
  final bool? canCompleteDelivery;
  final bool? canNavigate;
  final bool? canCallCustomer;
  final String? maskedPhoneNumber;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_delivery_manifest_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverDeliveryManifestResponseDto _$DriverDeliveryManifestResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverDeliveryManifestResponseDto(
  tripId: json['tripId'] as String?,
  tripCode: json['tripCode'] as String?,
  tripStatus: json['tripStatus'] as String?,
  tripStatusText: json['tripStatusText'] as String?,
  serverTimeUtc: json['serverTimeUtc'] as String?,
  counts: json['counts'] == null
      ? null
      : DriverDeliveryCountsResponseDto.fromJson(
          json['counts'] as Map<String, dynamic>,
        ),
  stops: (json['stops'] as List<dynamic>?)
      ?.map(
        (e) =>
            DriverDeliveryStopResponseDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

DriverDeliveryCountsResponseDto _$DriverDeliveryCountsResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverDeliveryCountsResponseDto(
  total: (json['total'] as num?)?.toInt(),
  inProgress: (json['inProgress'] as num?)?.toInt(),
  delivered: (json['delivered'] as num?)?.toInt(),
  failed: (json['failed'] as num?)?.toInt(),
);

DriverDeliveryStopResponseDto _$DriverDeliveryStopResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverDeliveryStopResponseDto(
  tripStopId: json['tripStopId'] as String?,
  boxId: json['boxId'] as String?,
  boxCode: json['boxCode'] as String?,
  sequenceNumber: (json['sequenceNumber'] as num?)?.toInt(),
  customerName: json['customerName'] as String?,
  deliveryZone: json['deliveryZone'] as String?,
  formattedAddress: json['formattedAddress'] as String?,
  latitude: json['latitude'] as num?,
  longitude: json['longitude'] as num?,
  mealsCount: (json['mealsCount'] as num?)?.toInt(),
  mealsSummary: json['mealsSummary'] as String?,
  deliveryTimeSlot: json['deliveryTimeSlot'] as String?,
  status: json['status'] as String?,
  statusText: json['statusText'] as String?,
  deliveredAtUtc: json['deliveredAtUtc'] as String?,
  failureReasonCategory: json['failureReasonCategory'] as String?,
  failureReasonText: json['failureReasonText'] as String?,
  isCurrentStop: json['isCurrentStop'] as bool?,
  canCompleteDelivery: json['canCompleteDelivery'] as bool?,
  canNavigate: json['canNavigate'] as bool?,
  canCallCustomer: json['canCallCustomer'] as bool?,
  maskedPhoneNumber: json['maskedPhoneNumber'] as String?,
);

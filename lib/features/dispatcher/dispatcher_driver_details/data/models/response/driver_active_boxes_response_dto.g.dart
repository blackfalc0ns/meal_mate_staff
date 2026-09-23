// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_active_boxes_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverActiveBoxesResponseDto _$DriverActiveBoxesResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverActiveBoxesResponseDto(
  totalCount: (json['totalCount'] as num?)?.toInt(),
  boxes: (json['boxes'] as List<dynamic>?)
      ?.map(
        (e) => e == null
            ? null
            : DriverActiveBoxDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

DriverActiveBoxDto _$DriverActiveBoxDtoFromJson(Map<String, dynamic> json) =>
    DriverActiveBoxDto(
      boxId: json['boxId'] as String?,
      boxCode: json['boxCode'] as String?,
      customerName: json['customerName'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      status: json['status'] as String?,
      statusText: json['statusText'] as String?,
      statusColor: json['statusColor'] as String?,
      scheduledTimeText: json['scheduledTimeText'] as String?,
      isDelivering: json['isDelivering'] as bool?,
    );

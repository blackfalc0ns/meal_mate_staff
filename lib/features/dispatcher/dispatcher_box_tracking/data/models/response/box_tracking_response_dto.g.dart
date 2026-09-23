// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_tracking_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoxTrackingResponseDto _$BoxTrackingResponseDtoFromJson(
  Map<String, dynamic> json,
) => BoxTrackingResponseDto(
  box: json['box'] == null
      ? null
      : BoxInfoDto.fromJson(json['box'] as Map<String, dynamic>),
  driver: json['driver'] == null
      ? null
      : BoxDriverDto.fromJson(json['driver'] as Map<String, dynamic>),
  details: json['details'] == null
      ? null
      : BoxDetailsInfoDto.fromJson(json['details'] as Map<String, dynamic>),
  timeline: (json['timeline'] as List<dynamic>?)
      ?.map(
        (e) => e == null
            ? null
            : BoxTimelineStepDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

BoxInfoDto _$BoxInfoDtoFromJson(Map<String, dynamic> json) => BoxInfoDto(
  boxId: json['boxId'] as String?,
  boxCode: json['boxCode'] as String?,
  status: json['status'] as String?,
  statusText: json['statusText'] as String?,
  statusColor: json['statusColor'] as String?,
  customerName: json['customerName'] as String?,
  scheduledTimeText: json['scheduledTimeText'] as String?,
  deliveryAddress: json['deliveryAddress'] as String?,
);

BoxDriverDto _$BoxDriverDtoFromJson(Map<String, dynamic> json) => BoxDriverDto(
  driverId: json['driverId'] as String?,
  driverCode: json['driverCode'] as String?,
  fullName: json['fullName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
);

BoxDetailsInfoDto _$BoxDetailsInfoDtoFromJson(Map<String, dynamic> json) =>
    BoxDetailsInfoDto(
      programType: json['programType'] as String?,
      orderDateText: json['orderDateText'] as String?,
      customerNotes: json['customerNotes'] as String?,
      mealsSummary: json['mealsSummary'] as String?,
    );

BoxTimelineStepDto _$BoxTimelineStepDtoFromJson(Map<String, dynamic> json) =>
    BoxTimelineStepDto(
      step: (json['step'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      time: json['time'] as String?,
      state: json['state'] as String?,
      icon: json['icon'] as String?,
    );

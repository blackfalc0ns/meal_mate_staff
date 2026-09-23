import 'package:json_annotation/json_annotation.dart';

part 'box_tracking_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class BoxTrackingResponseDto {
  const BoxTrackingResponseDto({
    this.box,
    this.driver,
    this.details,
    this.timeline,
  });

  factory BoxTrackingResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BoxTrackingResponseDtoFromJson(json);

  final BoxInfoDto? box;
  final BoxDriverDto? driver;
  final BoxDetailsInfoDto? details;
  final List<BoxTimelineStepDto?>? timeline;
}

@JsonSerializable(createToJson: false)
class BoxInfoDto {
  const BoxInfoDto({
    this.boxId,
    this.boxCode,
    this.status,
    this.statusText,
    this.statusColor,
    this.customerName,
    this.scheduledTimeText,
    this.deliveryAddress,
  });

  factory BoxInfoDto.fromJson(Map<String, dynamic> json) =>
      _$BoxInfoDtoFromJson(json);

  final String? boxId;
  final String? boxCode;
  final String? status;
  final String? statusText;
  final String? statusColor;
  final String? customerName;
  final String? scheduledTimeText;
  final String? deliveryAddress;
}

@JsonSerializable(createToJson: false)
class BoxDriverDto {
  const BoxDriverDto({
    this.driverId,
    this.driverCode,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
  });

  factory BoxDriverDto.fromJson(Map<String, dynamic> json) =>
      _$BoxDriverDtoFromJson(json);

  final String? driverId;
  final String? driverCode;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
}

@JsonSerializable(createToJson: false)
class BoxDetailsInfoDto {
  const BoxDetailsInfoDto({
    this.programType,
    this.orderDateText,
    this.customerNotes,
    this.mealsSummary,
  });

  factory BoxDetailsInfoDto.fromJson(Map<String, dynamic> json) =>
      _$BoxDetailsInfoDtoFromJson(json);

  final String? programType;
  final String? orderDateText;
  final String? customerNotes;
  final String? mealsSummary;
}

@JsonSerializable(createToJson: false)
class BoxTimelineStepDto {
  const BoxTimelineStepDto({
    this.step,
    this.title,
    this.description,
    this.time,
    this.state,
    this.icon,
  });

  factory BoxTimelineStepDto.fromJson(Map<String, dynamic> json) =>
      _$BoxTimelineStepDtoFromJson(json);

  final int? step;
  final String? title;
  final String? description;
  final String? time;
  final String? state;
  final String? icon;
}

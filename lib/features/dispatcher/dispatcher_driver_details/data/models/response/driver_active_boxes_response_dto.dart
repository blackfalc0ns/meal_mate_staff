import 'package:json_annotation/json_annotation.dart';

part 'driver_active_boxes_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverActiveBoxesResponseDto {
  const DriverActiveBoxesResponseDto({this.totalCount, this.boxes});

  factory DriverActiveBoxesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverActiveBoxesResponseDtoFromJson(json);

  final int? totalCount;
  final List<DriverActiveBoxDto?>? boxes;
}

@JsonSerializable(createToJson: false)
class DriverActiveBoxDto {
  const DriverActiveBoxDto({
    this.boxId,
    this.boxCode,
    this.customerName,
    this.deliveryAddress,
    this.status,
    this.statusText,
    this.statusColor,
    this.scheduledTimeText,
    this.isDelivering,
  });

  factory DriverActiveBoxDto.fromJson(Map<String, dynamic> json) =>
      _$DriverActiveBoxDtoFromJson(json);

  final String? boxId;
  final String? boxCode;
  final String? customerName;
  final String? deliveryAddress;
  final String? status;
  final String? statusText;
  final String? statusColor;
  final String? scheduledTimeText;
  final bool? isDelivering;
}

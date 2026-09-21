import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_live_driver_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherLiveDriverResponseDto {
  const DispatcherLiveDriverResponseDto({
    this.driverId,
    this.fullName,
    this.phone,
    this.plateNumber,
    this.avatarUrl,
    this.status,
    this.statusLabelAr,
    this.statusLabelEn,
    this.latitude,
    this.longitude,
    this.heading,
    this.speedKmh,
    this.activeOrderId,
    this.customerAddress,
    this.updatedAtUtc,
  });

  factory DispatcherLiveDriverResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherLiveDriverResponseDtoFromJson(json);

  final String? driverId;
  final String? fullName;
  final String? phone;
  final String? plateNumber;
  final String? avatarUrl;
  final String? status;
  final String? statusLabelAr;
  final String? statusLabelEn;
  final double? latitude;
  final double? longitude;
  final double? heading;
  final double? speedKmh;
  final String? activeOrderId;
  final String? customerAddress;
  final DateTime? updatedAtUtc;
}

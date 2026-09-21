// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_live_driver_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherLiveDriverResponseDto _$DispatcherLiveDriverResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherLiveDriverResponseDto(
  driverId: json['driverId'] as String?,
  fullName: json['fullName'] as String?,
  phone: json['phone'] as String?,
  plateNumber: json['plateNumber'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  status: json['status'] as String?,
  statusLabelAr: json['statusLabelAr'] as String?,
  statusLabelEn: json['statusLabelEn'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  heading: (json['heading'] as num?)?.toDouble(),
  speedKmh: (json['speedKmh'] as num?)?.toDouble(),
  activeOrderId: json['activeOrderId'] as String?,
  customerAddress: json['customerAddress'] as String?,
  updatedAtUtc: json['updatedAtUtc'] == null
      ? null
      : DateTime.parse(json['updatedAtUtc'] as String),
);

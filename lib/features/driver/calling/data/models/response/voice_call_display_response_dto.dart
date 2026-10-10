import 'package:json_annotation/json_annotation.dart';

part 'voice_call_display_response_dto.g.dart';

@JsonSerializable()
class VoiceCallDisplayResponseDto {
  const VoiceCallDisplayResponseDto({
    this.callId,
    this.tripStopId,
    this.driverName,
    this.driverImageUrl,
    this.driverRole,
    this.vehicleType,
    this.plateNumber,
    this.deliveryAddress,
    this.deliveryZone,
    this.orderCode,
    this.mealSummary,
    this.slotLabel,
    this.boxCount,
    this.stopStatus,
  });

  factory VoiceCallDisplayResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceCallDisplayResponseDtoFromJson(json);

  final String? callId;
  final String? tripStopId;
  final String? driverName;
  final String? driverImageUrl;
  final String? driverRole;
  final String? vehicleType;
  final String? plateNumber;
  final String? deliveryAddress;
  final String? deliveryZone;
  final String? orderCode;
  final String? mealSummary;
  final String? slotLabel;
  final int? boxCount;
  final String? stopStatus;

  Map<String, dynamic> toJson() => _$VoiceCallDisplayResponseDtoToJson(this);
}

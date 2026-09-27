import 'package:json_annotation/json_annotation.dart';

part 'driver_condition_photo_upload_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DriverConditionPhotoUploadResponseDto {
  const DriverConditionPhotoUploadResponseDto({
    this.boxId,
    this.conditionPhotoStorageKey,
    this.uploadedAtUtc,
    this.status,
    this.statusText,
    this.nextAction,
    this.message,
  });

  factory DriverConditionPhotoUploadResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DriverConditionPhotoUploadResponseDtoFromJson(json);

  final String? boxId;
  final String? conditionPhotoStorageKey;
  final String? uploadedAtUtc;
  final String? status;
  final String? statusText;
  final String? nextAction;
  final String? message;
}

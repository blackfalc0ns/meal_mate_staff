import 'package:json_annotation/json_annotation.dart';

part 'driver_delivery_proof_upload_response_dto.g.dart';

@JsonSerializable()
class DriverDeliveryProofUploadResponseDto {
  const DriverDeliveryProofUploadResponseDto({
    this.storageKey,
    this.uploadedAtUtc,
    this.fileUrl,
    this.message,
  });

  factory DriverDeliveryProofUploadResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawKey = json['storageKey'] ??
        json['key'] ??
        json['url'] ??
        json['fileUrl'] ??
        json['path'] ??
        json['data'];
    return DriverDeliveryProofUploadResponseDto(
      storageKey: rawKey?.toString(),
      uploadedAtUtc: (json['uploadedAtUtc'] ?? json['uploadedAt']) as String?,
      fileUrl: (json['fileUrl'] ?? json['url']) as String?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$DriverDeliveryProofUploadResponseDtoToJson(this);

  final String? storageKey;
  final String? uploadedAtUtc;
  final String? fileUrl;
  final String? message;
}

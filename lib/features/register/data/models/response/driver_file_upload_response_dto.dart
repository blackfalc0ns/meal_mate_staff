import 'package:json_annotation/json_annotation.dart';

part 'driver_file_upload_response_dto.g.dart';

@JsonSerializable()
class DriverFileUploadResponseDto {
  const DriverFileUploadResponseDto({
    this.storageKey,
    this.readUrl,
    this.fileName,
    this.contentType,
    this.sizeBytes,
  });

  factory DriverFileUploadResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverFileUploadResponseDtoFromJson(json);

  final String? storageKey;
  final String? readUrl;
  final String? fileName;
  final String? contentType;
  final int? sizeBytes;

  Map<String, dynamic> toJson() => _$DriverFileUploadResponseDtoToJson(this);
}

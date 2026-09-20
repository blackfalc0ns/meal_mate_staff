// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_file_upload_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverFileUploadResponseDto _$DriverFileUploadResponseDtoFromJson(
  Map<String, dynamic> json,
) => DriverFileUploadResponseDto(
  storageKey: json['storageKey'] as String?,
  readUrl: json['readUrl'] as String?,
  fileName: json['fileName'] as String?,
  contentType: json['contentType'] as String?,
  sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
);

Map<String, dynamic> _$DriverFileUploadResponseDtoToJson(
  DriverFileUploadResponseDto instance,
) => <String, dynamic>{
  'storageKey': instance.storageKey,
  'readUrl': instance.readUrl,
  'fileName': instance.fileName,
  'contentType': instance.contentType,
  'sizeBytes': instance.sizeBytes,
};

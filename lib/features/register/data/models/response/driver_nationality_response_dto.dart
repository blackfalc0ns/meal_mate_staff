import 'package:json_annotation/json_annotation.dart';

part 'driver_nationality_response_dto.g.dart';

@JsonSerializable()
class DriverNationalityResponseDto {
  const DriverNationalityResponseDto({
    this.code,
    this.name,
    this.nameAr,
    this.nameEn,
    this.countryName,
    this.countryNameAr,
    this.countryNameEn,
    this.flagEmoji,
  });

  factory DriverNationalityResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverNationalityResponseDtoFromJson(json);

  final String? code;
  final String? name;
  final String? nameAr;
  final String? nameEn;
  final String? countryName;
  final String? countryNameAr;
  final String? countryNameEn;
  final String? flagEmoji;

  Map<String, dynamic> toJson() => _$DriverNationalityResponseDtoToJson(this);
}

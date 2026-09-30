import 'package:json_annotation/json_annotation.dart';

part 'driver_phone_lookup_request_dto.g.dart';

@JsonSerializable()
class DriverPhoneLookupRequestDto {
  const DriverPhoneLookupRequestDto({required this.phone});

  factory DriverPhoneLookupRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverPhoneLookupRequestDtoFromJson(json);

  final String phone;

  Map<String, dynamic> toJson() => _$DriverPhoneLookupRequestDtoToJson(this);
}

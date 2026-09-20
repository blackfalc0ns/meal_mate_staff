import 'package:json_annotation/json_annotation.dart';

part 'phone_lookup_request_dto.g.dart';

@JsonSerializable()
class PhoneLookupRequestDto {
  const PhoneLookupRequestDto({required this.phone, required this.role});

  factory PhoneLookupRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PhoneLookupRequestDtoFromJson(json);

  final String phone;
  final String role;

  Map<String, dynamic> toJson() => _$PhoneLookupRequestDtoToJson(this);
}

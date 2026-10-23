import 'package:json_annotation/json_annotation.dart';

part 'phone_grant_response_dto.g.dart';

@JsonSerializable()
class PhoneGrantResponseDto {
  const PhoneGrantResponseDto({
    this.grantId,
    this.expiresAtUtc,
    this.customerPhone,
    this.contactCaseId,
  });

  factory PhoneGrantResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PhoneGrantResponseDtoFromJson(json);

  final String? grantId;
  final String? expiresAtUtc;
  final String? customerPhone;
  final String? contactCaseId;

  Map<String, dynamic> toJson() => _$PhoneGrantResponseDtoToJson(this);
}

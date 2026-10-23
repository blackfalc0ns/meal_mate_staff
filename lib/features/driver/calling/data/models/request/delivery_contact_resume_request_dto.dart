import 'package:json_annotation/json_annotation.dart';

part 'delivery_contact_resume_request_dto.g.dart';

@JsonSerializable()
class DeliveryContactResumeRequestDto {
  const DeliveryContactResumeRequestDto({
    this.lat,
    this.lng,
  });

  factory DeliveryContactResumeRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DeliveryContactResumeRequestDtoFromJson(json);

  final double? lat;
  final double? lng;

  Map<String, dynamic> toJson() => _$DeliveryContactResumeRequestDtoToJson(this);
}

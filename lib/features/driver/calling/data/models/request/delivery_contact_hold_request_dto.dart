import 'package:json_annotation/json_annotation.dart';

part 'delivery_contact_hold_request_dto.g.dart';

@JsonSerializable()
class DeliveryContactHoldRequestDto {
  const DeliveryContactHoldRequestDto({
    required this.notes,
    required this.firstAttemptCallId,
  });

  factory DeliveryContactHoldRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DeliveryContactHoldRequestDtoFromJson(json);

  final String notes;
  final String firstAttemptCallId;

  Map<String, dynamic> toJson() => _$DeliveryContactHoldRequestDtoToJson(this);
}

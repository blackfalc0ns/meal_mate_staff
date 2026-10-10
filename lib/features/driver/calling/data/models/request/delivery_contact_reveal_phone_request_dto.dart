import 'package:json_annotation/json_annotation.dart';

part 'delivery_contact_reveal_phone_request_dto.g.dart';

@JsonSerializable()
class DeliveryContactRevealPhoneRequestDto {
  const DeliveryContactRevealPhoneRequestDto({
    required this.clientRequestId,
    required this.reason,
    this.acknowledgedPrivacyWarning = true,
  });

  factory DeliveryContactRevealPhoneRequestDto.fromJson(
          Map<String, dynamic> json) =>
      _$DeliveryContactRevealPhoneRequestDtoFromJson(json);

  final String clientRequestId;
  final String reason;
  final bool acknowledgedPrivacyWarning;

  Map<String, dynamic> toJson() =>
      _$DeliveryContactRevealPhoneRequestDtoToJson(this);
}

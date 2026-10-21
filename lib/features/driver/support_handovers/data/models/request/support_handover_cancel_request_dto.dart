import 'package:json_annotation/json_annotation.dart';

part 'support_handover_cancel_request_dto.g.dart';

@JsonSerializable()
class SupportHandoverCancelRequestDto {
  const SupportHandoverCancelRequestDto({
    this.reason,
  });

  factory SupportHandoverCancelRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SupportHandoverCancelRequestDtoFromJson(json);

  final String? reason;

  Map<String, dynamic> toJson() => _$SupportHandoverCancelRequestDtoToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'handover_return_to_kitchen_request_dto.g.dart';

@JsonSerializable()
class HandoverReturnToKitchenRequestDto {
  const HandoverReturnToKitchenRequestDto({
    required this.manifestCode,
    required this.resolutionNote,
  });

  factory HandoverReturnToKitchenRequestDto.fromJson(
    Map<String, dynamic> json,
  ) => _$HandoverReturnToKitchenRequestDtoFromJson(json);

  final String manifestCode;
  final String resolutionNote;

  Map<String, dynamic> toJson() =>
      _$HandoverReturnToKitchenRequestDtoToJson(this);
}

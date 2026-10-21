import 'package:json_annotation/json_annotation.dart';

part 'support_handover_box_dto.g.dart';

@JsonSerializable()
class SupportHandoverBoxDto {
  const SupportHandoverBoxDto({
    this.tripStopId,
    this.manifestCode,
    this.status,
    this.receivedAtUtc,
    this.recordedAtUtc,
    this.followUpNote,
    this.followUpId,
    this.followUpStatus,
  });

  factory SupportHandoverBoxDto.fromJson(Map<String, dynamic> json) =>
      _$SupportHandoverBoxDtoFromJson(json);

  final String? tripStopId;
  final String? manifestCode;
  final String? status;
  final String? receivedAtUtc;
  final String? recordedAtUtc;
  final String? followUpNote;
  final String? followUpId;
  final String? followUpStatus;

  Map<String, dynamic> toJson() => _$SupportHandoverBoxDtoToJson(this);
}

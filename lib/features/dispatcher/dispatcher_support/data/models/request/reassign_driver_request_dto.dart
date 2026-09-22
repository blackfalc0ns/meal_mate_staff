import 'package:json_annotation/json_annotation.dart';

part 'reassign_driver_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class ReassignDriverRequestDto {
  const ReassignDriverRequestDto({
    required this.replacementDriverId,
    this.notes,
  });

  factory ReassignDriverRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ReassignDriverRequestDtoFromJson(json);

  final String replacementDriverId;
  final String? notes;

  Map<String, dynamic> toJson() => _$ReassignDriverRequestDtoToJson(this);
}

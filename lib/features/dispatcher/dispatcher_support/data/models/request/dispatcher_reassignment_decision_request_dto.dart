import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_reassignment_decision_request_dto.g.dart';

@JsonSerializable()
class DispatcherReassignmentDecisionRequestDto {
  const DispatcherReassignmentDecisionRequestDto({
    this.notes,
  });

  factory DispatcherReassignmentDecisionRequestDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherReassignmentDecisionRequestDtoFromJson(json);

  final String? notes;

  Map<String, dynamic> toJson() =>
      _$DispatcherReassignmentDecisionRequestDtoToJson(this);
}

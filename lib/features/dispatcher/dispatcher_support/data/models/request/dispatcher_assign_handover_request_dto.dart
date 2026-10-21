import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_assign_handover_request_dto.g.dart';

@JsonSerializable()
class DispatcherAssignHandoverRequestDto {
  const DispatcherAssignHandoverRequestDto({
    required this.replacementDriverId,
    required this.idempotencyKey,
    this.notes,
  });

  factory DispatcherAssignHandoverRequestDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherAssignHandoverRequestDtoFromJson(json);

  final String replacementDriverId;
  final String idempotencyKey;
  final String? notes;

  Map<String, dynamic> toJson() =>
      _$DispatcherAssignHandoverRequestDtoToJson(this);
}

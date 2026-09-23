import 'package:json_annotation/json_annotation.dart';

part 'assign_driver_request_dto.g.dart';

@JsonSerializable()
class AssignDriverRequestDto {
  const AssignDriverRequestDto({required this.driverId, required this.notes});

  factory AssignDriverRequestDto.fromJson(Map<String, dynamic> json) =>
      _$AssignDriverRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssignDriverRequestDtoToJson(this);

  final String driverId;
  final String notes;
}

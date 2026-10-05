import 'package:json_annotation/json_annotation.dart';

part 'update_driver_availability_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateDriverAvailabilityRequestDto {
  const UpdateDriverAvailabilityRequestDto({
    required this.isAvailable,
    this.reason,
  });

  factory UpdateDriverAvailabilityRequestDto.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateDriverAvailabilityRequestDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateDriverAvailabilityRequestDtoToJson(this);

  @JsonKey(
    name: 'shiftStatus',
    fromJson: _statusFromJson,
    toJson: _statusToJson,
  )
  final bool isAvailable;
  @JsonKey(includeToJson: false)
  final String? reason;

  static bool _statusFromJson(String value) => value == 'Active';
  static String _statusToJson(bool value) => value ? 'Active' : 'Inactive';
}

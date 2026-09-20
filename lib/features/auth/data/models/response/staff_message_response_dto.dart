import 'package:json_annotation/json_annotation.dart';

part 'staff_message_response_dto.g.dart';

@JsonSerializable()
class StaffMessageResponseDto {
  const StaffMessageResponseDto({
    this.success,
    this.message,
  });

  factory StaffMessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$StaffMessageResponseDtoFromJson(json);

  final bool? success;
  final String? message;

  Map<String, dynamic> toJson() => _$StaffMessageResponseDtoToJson(this);
}

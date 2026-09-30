import 'package:json_annotation/json_annotation.dart';

part 'driver_message_response_dto.g.dart';

@JsonSerializable()
class DriverMessageResponseDto {
  const DriverMessageResponseDto({this.message, this.success});

  factory DriverMessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverMessageResponseDtoFromJson(json);

  final String? message;
  final bool? success;

  Map<String, dynamic> toJson() => _$DriverMessageResponseDtoToJson(this);
}

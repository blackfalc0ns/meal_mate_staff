import 'package:json_annotation/json_annotation.dart';

part 'staff_login_request_dto.g.dart';

@JsonSerializable()
class StaffLoginRequestDto {
  const StaffLoginRequestDto({
    required this.phone,
    required this.role,
    required this.password,
  });

  factory StaffLoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$StaffLoginRequestDtoFromJson(json);

  final String phone;
  final String role;
  final String password;

  Map<String, dynamic> toJson() => _$StaffLoginRequestDtoToJson(this);
}

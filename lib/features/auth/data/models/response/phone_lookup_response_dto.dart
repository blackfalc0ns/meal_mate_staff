import 'package:json_annotation/json_annotation.dart';

import 'staff_application_status_dto.dart';

part 'phone_lookup_response_dto.g.dart';

@JsonSerializable()
class PhoneLookupResponseDto {
  const PhoneLookupResponseDto({
    this.exists,
    this.isFirstTimeSetup,
    this.role,
    this.phone,
    this.fullName,
    this.restaurantName,
    this.restaurantId,
    this.status,
    this.applicationStatus,
  });

  factory PhoneLookupResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PhoneLookupResponseDtoFromJson(json);

  final bool? exists;
  final bool? isFirstTimeSetup;
  final String? role;
  final String? phone;
  final String? fullName;
  final String? restaurantName;
  final String? restaurantId;
  final String? status;
  final StaffApplicationStatusDto? applicationStatus;

  Map<String, dynamic> toJson() => _$PhoneLookupResponseDtoToJson(this);
}

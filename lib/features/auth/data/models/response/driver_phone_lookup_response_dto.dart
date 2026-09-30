import 'package:json_annotation/json_annotation.dart';

part 'driver_phone_lookup_response_dto.g.dart';

@JsonSerializable()
class DriverPhoneLookupResponseDto {
  const DriverPhoneLookupResponseDto({
    this.exists,
    this.requiresFirstTimeSetup,
    this.fullName,
    this.restaurantName,
    this.accountStatus,
  });

  factory DriverPhoneLookupResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverPhoneLookupResponseDtoFromJson(json);

  final bool? exists;
  @JsonKey(readValue: _readFirstTimeSetup)
  final bool? requiresFirstTimeSetup;
  final String? fullName;
  final String? restaurantName;
  @JsonKey(readValue: _readAccountStatus)
  final String? accountStatus;

  static Object? _readFirstTimeSetup(Map json, String key) {
    return json['requiresFirstTimeSetup'] ?? json['isFirstTimeSetup'];
  }

  static Object? _readAccountStatus(Map json, String key) {
    return json['accountStatus'] ?? json['status'];
  }

  Map<String, dynamic> toJson() => _$DriverPhoneLookupResponseDtoToJson(this);
}

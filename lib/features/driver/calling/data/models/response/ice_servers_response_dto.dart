import 'package:json_annotation/json_annotation.dart';

part 'ice_servers_response_dto.g.dart';

@JsonSerializable()
class IceServerDto {
  const IceServerDto({
    this.urls,
    this.username,
    this.credential,
  });

  factory IceServerDto.fromJson(Map<String, dynamic> json) =>
      _$IceServerDtoFromJson(json);

  final List<String>? urls;
  final String? username;
  final String? credential;

  Map<String, dynamic> toJson() => _$IceServerDtoToJson(this);
}

@JsonSerializable()
class IceServersResponseDto {
  const IceServersResponseDto({
    this.iceServers,
  });

  factory IceServersResponseDto.fromJson(Map<String, dynamic> json) =>
      _$IceServersResponseDtoFromJson(json);

  final List<IceServerDto>? iceServers;

  Map<String, dynamic> toJson() => _$IceServersResponseDtoToJson(this);
}

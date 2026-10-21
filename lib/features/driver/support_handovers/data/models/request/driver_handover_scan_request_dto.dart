import 'package:json_annotation/json_annotation.dart';

part 'driver_handover_scan_request_dto.g.dart';

@JsonSerializable()
class DriverHandoverScanRequestDto {
  const DriverHandoverScanRequestDto({
    required this.code,
    required this.status,
    required this.method,
    this.followUpNote,
  });

  factory DriverHandoverScanRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverHandoverScanRequestDtoFromJson(json);

  final String code;
  final String status;
  final String method;
  final String? followUpNote;

  Map<String, dynamic> toJson() => _$DriverHandoverScanRequestDtoToJson(this);
}

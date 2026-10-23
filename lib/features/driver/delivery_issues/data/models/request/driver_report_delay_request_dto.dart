import 'package:json_annotation/json_annotation.dart';

part 'driver_report_delay_request_dto.g.dart';

@JsonSerializable()
class DriverReportDelayRequestDto {
  const DriverReportDelayRequestDto({
    required this.delayMinutes,
    this.reason,
  });

  factory DriverReportDelayRequestDto.fromJson(Map<String, dynamic> json) =>
      _$DriverReportDelayRequestDtoFromJson(json);

  final int delayMinutes;
  final String? reason;

  Map<String, dynamic> toJson() => _$DriverReportDelayRequestDtoToJson(this);
}

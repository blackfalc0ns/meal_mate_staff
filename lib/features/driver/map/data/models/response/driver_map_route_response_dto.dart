import 'package:json_annotation/json_annotation.dart';

import 'driver_map_location_response_dto.dart';
import 'driver_map_navigation_response_dto.dart';
import 'driver_map_stop_response_dto.dart';

part 'driver_map_route_response_dto.g.dart';

@JsonSerializable()
class DriverMapRouteResponseDto {
  const DriverMapRouteResponseDto({
    this.tripId,
    this.tripCode,
    this.driverLatitude,
    this.driverLongitude,
    this.totalStopsCount,
    this.completedStopsCount,
    this.focusedStop,
    this.stops,
    this.routePolylineWaypoints,
    this.navigation,
  });

  factory DriverMapRouteResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DriverMapRouteResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverMapRouteResponseDtoToJson(this);

  final String? tripId;
  final String? tripCode;
  final double? driverLatitude;
  final double? driverLongitude;
  final int? totalStopsCount;
  final int? completedStopsCount;
  final DriverMapStopResponseDto? focusedStop;
  final List<DriverMapStopResponseDto>? stops;
  final List<DriverMapLocationResponseDto>? routePolylineWaypoints;
  final DriverMapNavigationResponseDto? navigation;
}

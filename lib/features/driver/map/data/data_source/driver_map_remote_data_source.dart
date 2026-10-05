import '../models/response/driver_map_route_response_dto.dart';

abstract class DriverMapRemoteDataSource {
  Future<DriverMapRouteResponseDto> getDriverMapRoute({
    String? focusedStopId,
  });
}

import 'package:injectable/injectable.dart';

import 'package:meal_mate_delivery/core/network/api_services.dart';
import '../models/response/driver_map_route_response_dto.dart';
import 'driver_map_remote_data_source.dart';

@Injectable(as: DriverMapRemoteDataSource)
class DriverMapRemoteDataSourceImpl implements DriverMapRemoteDataSource {
  const DriverMapRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverMapRouteResponseDto> getDriverMapRoute({
    String? focusedStopId,
  }) {
    return _apiServices.getDriverMapRoute(focusedStopId);
  }
}

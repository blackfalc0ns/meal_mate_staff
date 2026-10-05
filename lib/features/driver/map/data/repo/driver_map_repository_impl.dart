import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';

import '../../domain/entities/driver_map_route_entity.dart';
import '../../domain/repo/driver_map_repository.dart';
import '../data_source/driver_map_remote_data_source.dart';
import '../mapper/driver_map_mapper.dart';

@LazySingleton(as: DriverMapRepository)
class DriverMapRepositoryImpl implements DriverMapRepository {
  const DriverMapRepositoryImpl(this._remoteDataSource);

  final DriverMapRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DriverMapRouteEntity>> getDriverMapRoute({
    String? focusedStopId,
  }) {
    return safeApiCall(() async {
      final dto = await _remoteDataSource.getDriverMapRoute(
        focusedStopId: focusedStopId,
      );
      return dto.toEntity();
    });
  }
}

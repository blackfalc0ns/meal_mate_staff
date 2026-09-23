import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_active_box_entity.dart';
import '../../domain/entities/driver_current_location_entity.dart';
import '../../domain/entities/driver_details_entity.dart';
import '../../domain/repo/driver_details_repository.dart';
import '../data_source/driver_details_remote_data_source.dart';
import '../mapper/driver_details_mapper.dart';

@LazySingleton(as: DriverDetailsRepository)
class DriverDetailsRepositoryImpl implements DriverDetailsRepository {
  const DriverDetailsRepositoryImpl(this._remoteDataSource);

  final DriverDetailsRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DriverDetailsEntity>> getDetails(String driverId) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getDetails(driverId);
      return response.toEntity();
    });
  }

  @override
  Future<ApiResult<List<DriverActiveBoxEntity>>> getActiveBoxes(
    String driverId,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getActiveBoxes(driverId);
      return response.toEntityList();
    });
  }

  @override
  Future<ApiResult<DriverCurrentLocationEntity>> getCurrentLocation(
    String driverId,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getCurrentLocation(driverId);
      return response.toEntity();
    });
  }
}

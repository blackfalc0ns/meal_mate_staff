import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';

import '../../domain/entities/driver_home_entity.dart';
import '../../domain/repo/driver_home_repository.dart';
import '../data_source/driver_home_remote_data_source.dart';
import '../mapper/driver_home_mapper.dart';

@LazySingleton(as: DriverHomeRepository)
class DriverHomeRepositoryImpl implements DriverHomeRepository {
  DriverHomeRepositoryImpl(this._remoteDataSource);

  final DriverHomeRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DriverHomeEntity>> getDriverHome() {
    return safeApiCall(() async {
      final dto = await _remoteDataSource.getDriverHome();
      return dto.toEntity();
    });
  }
}

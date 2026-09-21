import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_home_map_driver_pin_entity.dart';
import '../../domain/entities/dispatcher_home_overview_entity.dart';
import '../../domain/repo/dispatcher_home_repository.dart';
import '../data_source/dispatcher_home_remote_data_source.dart';
import '../mapper/dispatcher_home_mapper.dart';

@LazySingleton(as: DispatcherHomeRepository)
class DispatcherHomeRepositoryImpl implements DispatcherHomeRepository {
  const DispatcherHomeRepositoryImpl(this._remoteDataSource);

  final DispatcherHomeRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DispatcherHomeOverviewEntity>> getOverview() {
    return safeApiCall(
      () async => (await _remoteDataSource.getOverview()).toEntity(),
    );
  }

  @override
  Future<ApiResult<List<DispatcherHomeMapDriverPinEntity>>> getLiveDrivers() {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getLiveDrivers();
      return response
          .map((driver) => driver.toEntity())
          .toList(growable: false);
    });
  }
}

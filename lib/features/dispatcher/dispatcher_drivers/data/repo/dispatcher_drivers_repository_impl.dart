import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';

import '../../domain/entities/assign_driver_request_entity.dart';
import '../../domain/entities/dispatcher_drivers_query_entity.dart';
import '../../domain/entities/dispatcher_drivers_roster_entity.dart';
import '../../domain/entities/driver_assignment_result_entity.dart';
import '../../domain/repo/dispatcher_drivers_repository.dart';
import '../data_source/dispatcher_drivers_remote_data_source.dart';
import '../mapper/dispatcher_drivers_mapper.dart';

@LazySingleton(as: DispatcherDriversRepository)
class DispatcherDriversRepositoryImpl implements DispatcherDriversRepository {
  const DispatcherDriversRepositoryImpl(this._remoteDataSource);

  final DispatcherDriversRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DispatcherDriversRosterEntity>> getRoster(
    DispatcherDriversQueryEntity query,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getRoster(
        view: query.view.apiValue,
        area: query.areaKey ?? query.areaName,
        boxId: query.boxId,
      );
      return response.toEntity();
    });
  }

  @override
  Future<ApiResult<DriverAssignmentResultEntity>> assignDriver(
    AssignDriverRequestEntity request,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.assignDriver(
        boxId: request.boxId,
        request: request.toDto(),
      );
      return response.toEntity();
    });
  }
}

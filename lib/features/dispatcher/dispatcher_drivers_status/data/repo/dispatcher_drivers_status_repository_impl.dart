import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_driver_details_entity.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../../domain/entities/dispatcher_drivers_status_query_entity.dart';
import '../../domain/entities/dispatcher_drivers_status_summary_entity.dart';
import '../../domain/entities/update_driver_availability_request_entity.dart';
import '../../domain/entities/update_driver_availability_result_entity.dart';
import '../../domain/repo/dispatcher_drivers_status_repository.dart';
import '../data_source/dispatcher_drivers_status_remote_data_source.dart';
import '../mapper/dispatcher_driver_details_mapper.dart';
import '../mapper/dispatcher_drivers_status_mapper.dart';
import '../realtime/dispatcher_drivers_status_realtime_client.dart';

@LazySingleton(as: DispatcherDriversStatusRepository)
class DispatcherDriversStatusRepositoryImpl
    implements DispatcherDriversStatusRepository {
  const DispatcherDriversStatusRepositoryImpl(
    this._remoteDataSource,
    this._realtimeClient,
  );

  final DispatcherDriversStatusRemoteDataSource _remoteDataSource;
  final DispatcherDriversStatusRealtimeClient _realtimeClient;

  @override
  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus([
    DispatcherDriversStatusQueryEntity query =
        const DispatcherDriversStatusQueryEntity(),
  ]) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getDriversStatus(
        search: query.search,
        status: query.status?.apiValue ?? 'All',
        sortBy: query.sortBy.apiValue,
        pageNumber: query.pageNumber,
        pageSize: query.pageSize,
      );
      return DispatcherDriversStatusMapper.toEntity(response);
    });
  }

  @override
  Future<ApiResult<UpdateDriverAvailabilityResultEntity>>
  toggleDriverAvailability(UpdateDriverAvailabilityRequestEntity request) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.updateDriverAvailability(
        request.driverId,
        request.toDto(),
      );
      return DispatcherDriversStatusMapper.toAvailabilityResult(response);
    });
  }

  @override
  Future<ApiResult<DispatcherDriverDetailsEntity>> getDriverDetails(
    String driverId,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getDriverDetails(driverId);
      return DispatcherDriverDetailsMapper.toEntity(
        response,
        fallbackDriverId: driverId,
      );
    });
  }

  @override
  Stream<UpdateDriverAvailabilityResultEntity> get driverAvailabilityUpdates =>
      _realtimeClient.events.map((event) {
        DateTime? parsedDate;
        if (event.updatedAtUtc != null) {
          parsedDate = DateTime.tryParse(event.updatedAtUtc!)?.toUtc();
        }
        return UpdateDriverAvailabilityResultEntity(
          driverId: event.driverId,
          isAvailable: event.isAvailable,
          operationalStatus: DispatcherDriverStatusType.fromApi(
            event.operationalStatus,
          ),
          updatedAtUtc: parsedDate,
        );
      });

  @override
  Future<void> acquireRealtime(String ownerId) =>
      _realtimeClient.acquire(ownerId);

  @override
  Future<void> releaseRealtime(String ownerId) =>
      _realtimeClient.release(ownerId);
}

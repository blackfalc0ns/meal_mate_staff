import 'package:injectable/injectable.dart';
import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_drivers_status_summary_entity.dart';
import '../../domain/repo/dispatcher_drivers_status_repository.dart';
import '../data_source/dispatcher_drivers_status_remote_data_source.dart';
import '../mapper/dispatcher_drivers_status_mapper.dart';

@LazySingleton(as: DispatcherDriversStatusRepository)
class DispatcherDriversStatusRepositoryImpl implements DispatcherDriversStatusRepository {
  const DispatcherDriversStatusRepositoryImpl(this._remoteDataSource);

  final DispatcherDriversStatusRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus() {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getDriversStatus();
      return response.toEntity();
    });
  }

  @override
  Future<ApiResult<bool>> toggleDriverAvailability(String driverId, bool isAvailable) {
    return safeApiCall(() async {
      final result = await _remoteDataSource.toggleDriverAvailability(driverId, isAvailable);
      return result;
    });
  }
}

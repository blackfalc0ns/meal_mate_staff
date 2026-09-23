import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_performance_comparison_entity.dart';
import '../../domain/entities/driver_performance_overview_entity.dart';
import '../../domain/entities/driver_performance_query_entity.dart';
import '../../domain/repo/driver_performance_repository.dart';
import '../data_source/driver_performance_remote_data_source.dart';
import '../mapper/driver_performance_mapper.dart';

@LazySingleton(as: DriverPerformanceRepository)
class DriverPerformanceRepositoryImpl implements DriverPerformanceRepository {
  const DriverPerformanceRepositoryImpl(this._remoteDataSource);

  final DriverPerformanceRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DriverPerformanceOverviewEntity>> getOverview(
    DriverPerformanceQueryEntity query,
  ) {
    return safeApiCall(
      () async => (await _remoteDataSource.getOverview(query)).toEntity(),
    );
  }

  @override
  Future<ApiResult<DriverPerformanceComparisonEntity>> getComparison(
    DriverPerformanceQueryEntity query,
  ) {
    return safeApiCall(
      () async => (await _remoteDataSource.getComparison(query)).toEntity(),
    );
  }
}

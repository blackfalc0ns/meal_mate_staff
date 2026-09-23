import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../../domain/entities/driver_performance_query_entity.dart';
import '../models/response/driver_performance_comparison_response_dto.dart';
import '../models/response/driver_performance_overview_response_dto.dart';
import 'driver_performance_remote_data_source.dart';

@LazySingleton(as: DriverPerformanceRemoteDataSource)
class DriverPerformanceRemoteDataSourceImpl
    implements DriverPerformanceRemoteDataSource {
  const DriverPerformanceRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverPerformanceOverviewResponseDto> getOverview(
    DriverPerformanceQueryEntity query,
  ) {
    return _apiServices.getDriverPerformanceOverview(
      period: query.period.apiValue,
      fromDate: query.fromDateFormatted,
      toDate: query.toDateFormatted,
    );
  }

  @override
  Future<DriverPerformanceComparisonResponseDto> getComparison(
    DriverPerformanceQueryEntity query,
  ) {
    return _apiServices.getDriverPerformanceComparison(
      period: query.period.apiValue,
      driverIds: query.driverIds,
      fromDate: query.fromDateFormatted,
      toDate: query.toDateFormatted,
    );
  }
}

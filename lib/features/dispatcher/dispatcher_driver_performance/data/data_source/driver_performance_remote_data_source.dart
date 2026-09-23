import '../../domain/entities/driver_performance_query_entity.dart';
import '../models/response/driver_performance_comparison_response_dto.dart';
import '../models/response/driver_performance_overview_response_dto.dart';

abstract class DriverPerformanceRemoteDataSource {
  Future<DriverPerformanceOverviewResponseDto> getOverview(
    DriverPerformanceQueryEntity query,
  );

  Future<DriverPerformanceComparisonResponseDto> getComparison(
    DriverPerformanceQueryEntity query,
  );
}

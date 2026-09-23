import '../../../../../core/network/api_results.dart';
import '../entities/driver_performance_comparison_entity.dart';
import '../entities/driver_performance_overview_entity.dart';
import '../entities/driver_performance_query_entity.dart';

abstract class DriverPerformanceRepository {
  Future<ApiResult<DriverPerformanceOverviewEntity>> getOverview(
    DriverPerformanceQueryEntity query,
  );

  Future<ApiResult<DriverPerformanceComparisonEntity>> getComparison(
    DriverPerformanceQueryEntity query,
  );
}

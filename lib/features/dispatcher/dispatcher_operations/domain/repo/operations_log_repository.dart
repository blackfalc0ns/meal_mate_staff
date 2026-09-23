import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/operations_page_entity.dart';
import '../entities/operations_query_entity.dart';

abstract interface class OperationsLogRepository {
  Future<ApiResult<OperationsPageEntity>> getOperations(
    OperationsQueryEntity query,
  );
}

import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/dispatcher_support_query_entity.dart';
import '../entities/dispatcher_support_response_entity.dart';

abstract class DispatcherSupportRepository {
  Future<ApiResult<DispatcherSupportResponseEntity>> getIssues(
    DispatcherSupportQueryEntity query,
  );
}

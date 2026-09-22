import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/dispatcher_support_query_entity.dart';
import '../entities/dispatcher_support_response_entity.dart';
import '../repo/dispatcher_support_repository.dart';

class GetDispatcherSupportIssuesUseCase {
  const GetDispatcherSupportIssuesUseCase(this._repository);

  final DispatcherSupportRepository _repository;

  Future<ApiResult<DispatcherSupportResponseEntity>> call(
    DispatcherSupportQueryEntity query,
  ) {
    return _repository.getIssues(query);
  }
}

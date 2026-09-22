import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/dispatcher_issue_detail_entity.dart';
import '../repo/dispatcher_support_repository.dart';

class GetDispatcherIssueDetailsUseCase {
  const GetDispatcherIssueDetailsUseCase(this._repository);

  final DispatcherSupportRepository _repository;

  Future<ApiResult<DispatcherIssueDetailEntity>> call(String issueId) {
    return _repository.getIssueDetails(issueId.trim());
  }
}

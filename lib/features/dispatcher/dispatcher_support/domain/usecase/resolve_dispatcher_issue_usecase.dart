import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/resolve_issue_result_entity.dart';
import '../repo/dispatcher_support_repository.dart';

@injectable
class ResolveDispatcherIssueUseCase {
  const ResolveDispatcherIssueUseCase(this._repository);

  final DispatcherSupportRepository _repository;

  Future<ApiResult<ResolveIssueResultEntity>> call(
    String issueId,
    String resolutionNotes,
  ) {
    return _repository.resolveIssue(issueId.trim(), resolutionNotes.trim());
  }
}

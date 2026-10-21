import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../repo/driver_issue_repository.dart';

class ReportDriverDelayUseCase {
  const ReportDriverDelayUseCase(this._repository);

  final DriverIssueRepository _repository;

  Future<ApiResult<bool>> call({
    required String boxId,
    required int delayMinutes,
    String? reason,
  }) {
    return _repository.reportDelay(
      boxId: boxId,
      delayMinutes: delayMinutes,
      reason: reason,
    );
  }
}

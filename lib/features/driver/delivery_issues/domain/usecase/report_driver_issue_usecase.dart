import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/delivery_issue_reason.dart';
import '../repo/driver_issue_repository.dart';

class ReportDriverIssueUseCase {
  const ReportDriverIssueUseCase(this._repository);

  final DriverIssueRepository _repository;

  Future<ApiResult<String>> call({
    required String boxId,
    required DeliveryIssueReason reason,
    String? description,
    String? severity,
    List<String> photoStorageKeys = const [],
  }) {
    return _repository.reportIssue(
      boxId: boxId,
      reason: reason,
      description: description,
      severity: severity,
      photoStorageKeys: photoStorageKeys,
    );
  }
}

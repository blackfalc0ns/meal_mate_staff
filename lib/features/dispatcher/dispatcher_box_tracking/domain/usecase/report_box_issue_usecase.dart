import 'package:injectable/injectable.dart';

import '../../../../../core/errors/api_error_type.dart';
import '../../../../../core/errors/api_exception.dart';
import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/failures.dart';
import '../entities/report_box_issue_request_entity.dart';
import '../entities/report_box_issue_result_entity.dart';
import '../repo/box_tracking_repository.dart';

@injectable
class ReportBoxIssueUseCase {
  const ReportBoxIssueUseCase(this._repository);

  final BoxTrackingRepository _repository;

  static final RegExp _guidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<ApiResult<ReportBoxIssueResultEntity>> call(
    String boxId,
    ReportBoxIssueRequestEntity request,
  ) {
    final trimmedBoxId = boxId.trim();
    if (trimmedBoxId.isEmpty || !_guidRegex.hasMatch(trimmedBoxId)) {
      return Future.value(
        ApiErrorResult(
          failure: Failure(
            errorMessage: 'Invalid box ID: must be a valid GUID.',
            code: 'validationError',
            exception: const ApiException(
              errorType: ApiErrorType.validationError,
              message: 'Invalid box ID: must be a valid GUID.',
            ),
          ),
        ),
      );
    }

    final trimmedDescription = request.description.trim();
    if (trimmedDescription.isEmpty) {
      return Future.value(
        ApiErrorResult(
          failure: Failure(
            errorMessage: 'Description cannot be empty.',
            code: 'validationError',
            exception: const ApiException(
              errorType: ApiErrorType.validationError,
              message: 'Description cannot be empty.',
            ),
          ),
        ),
      );
    }

    final sanitizedRequest = ReportBoxIssueRequestEntity(
      issueType: request.issueType,
      description: trimmedDescription,
      severity: request.severity,
    );

    return _repository.reportIssue(trimmedBoxId, sanitizedRequest);
  }
}

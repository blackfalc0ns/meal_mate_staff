import 'dart:io';

import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../repo/driver_issue_repository.dart';

class UploadDriverIssueEvidenceUseCase {
  const UploadDriverIssueEvidenceUseCase(this._repository);

  final DriverIssueRepository _repository;

  Future<ApiResult<String>> call(File file) {
    return _repository.uploadEvidence(file);
  }
}

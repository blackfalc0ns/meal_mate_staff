import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_support_add_photos_result_entity.dart';
import '../repo/driver_support_repository.dart';

@injectable
class AddDriverSupportIssuePhotosUseCase {
  const AddDriverSupportIssuePhotosUseCase(this._repository);

  final DriverSupportRepository _repository;

  Future<ApiResult<DriverSupportAddPhotosResultEntity>> call({
    required String issueId,
    required List<String> storageKeys,
  }) {
    return _repository.addSupportIssuePhotos(issueId, storageKeys);
  }
}

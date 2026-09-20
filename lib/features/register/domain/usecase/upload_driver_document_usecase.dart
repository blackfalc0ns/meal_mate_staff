import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/driver_file_upload_result_entity.dart';
import '../repo/driver_registration_repository.dart';

@injectable
class UploadDriverDocumentUseCase {
  const UploadDriverDocumentUseCase(this._repository);

  final DriverRegistrationRepository _repository;

  Future<ApiResult<DriverFileUploadResultEntity>> call(File file) =>
      _repository.uploadDocument(file);
}

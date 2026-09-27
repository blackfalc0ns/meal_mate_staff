import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_condition_photo_upload_entity.dart';
import '../repo/driver_pickup_repository.dart';

@injectable
class UploadDriverBoxConditionPhotoUseCase {
  const UploadDriverBoxConditionPhotoUseCase(this._repository);

  final DriverPickupRepository _repository;

  Future<ApiResult<DriverConditionPhotoUploadEntity>> call({
    required String boxId,
    required File file,
    required String validationToken,
  }) {
    return _repository.uploadDriverBoxConditionPhoto(
      boxId: boxId,
      file: file,
      validationToken: validationToken,
    );
  }
}

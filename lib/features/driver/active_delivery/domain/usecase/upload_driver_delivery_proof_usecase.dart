import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_delivery_proof_upload_entity.dart';
import '../repo/driver_delivery_repository.dart';

@injectable
class UploadDriverDeliveryProofUseCase {
  const UploadDriverDeliveryProofUseCase(this._repository);

  final DriverDeliveryRepository _repository;

  Future<ApiResult<DriverDeliveryProofUploadEntity>> call({
    required String localPath,
  }) {
    return _repository.uploadProof(localPath: localPath);
  }
}

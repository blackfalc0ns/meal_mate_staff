import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_barcode_validation_entity.dart';
import '../entities/validate_driver_barcode_request_entity.dart';
import '../repo/driver_pickup_repository.dart';

@injectable
class ValidateDriverPickupBarcodeUseCase {
  const ValidateDriverPickupBarcodeUseCase(this._repository);

  final DriverPickupRepository _repository;

  Future<ApiResult<DriverBarcodeValidationEntity>> call(
    ValidateDriverBarcodeRequestEntity request,
  ) {
    return _repository.validateDriverPickupBarcode(request);
  }
}

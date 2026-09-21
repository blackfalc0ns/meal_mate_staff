import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/driver_vehicle_type_entity.dart';
import '../repo/driver_registration_repository.dart';

@injectable
class GetDriverVehicleTypesUseCase {
  const GetDriverVehicleTypesUseCase(this._repository);

  final DriverRegistrationRepository _repository;

  Future<ApiResult<List<DriverVehicleTypeEntity>>> call() =>
      _repository.getVehicleTypes();
}

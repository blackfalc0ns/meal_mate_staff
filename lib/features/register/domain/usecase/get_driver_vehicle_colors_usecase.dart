import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/driver_vehicle_color_entity.dart';
import '../repo/driver_registration_repository.dart';

@injectable
class GetDriverVehicleColorsUseCase {
  const GetDriverVehicleColorsUseCase(this._repository);

  final DriverRegistrationRepository _repository;

  Future<ApiResult<List<DriverVehicleColorEntity>>> call() =>
      _repository.getVehicleColors();
}

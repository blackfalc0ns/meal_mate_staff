import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/driver_vehicle_model_entity.dart';
import '../repo/driver_registration_repository.dart';

@injectable
class SearchDriverVehicleModelsUseCase {
  const SearchDriverVehicleModelsUseCase(this._repository);

  final DriverRegistrationRepository _repository;

  Future<ApiResult<List<DriverVehicleModelEntity>>> call({
    String? search,
    String? vehicleType,
    int limit = 40,
  }) => _repository.searchVehicleModels(
    search: search,
    vehicleType: vehicleType,
    limit: limit,
  );
}

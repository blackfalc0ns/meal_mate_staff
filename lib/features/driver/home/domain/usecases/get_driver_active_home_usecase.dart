import '../entities/driver_active_home_entity.dart';
import '../repositories/driver_home_repository.dart';

class GetDriverActiveHomeUseCase {
  const GetDriverActiveHomeUseCase(this._repository);

  final DriverHomeRepository _repository;

  Future<DriverActiveHomeEntity> call() => _repository.getActiveHomeOverview();
}

import '../entities/driver_start_work_entity.dart';
import '../repositories/driver_home_repository.dart';

class GetDriverStartWorkUseCase {
  const GetDriverStartWorkUseCase(this._repository);

  final DriverHomeRepository _repository;

  Future<DriverStartWorkEntity> call() => _repository.getStartWorkOverview();
}

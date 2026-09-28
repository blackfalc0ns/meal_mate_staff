import '../repositories/driver_home_repository.dart';

class StartDriverShiftUseCase {
  const StartDriverShiftUseCase(this._repository);

  final DriverHomeRepository _repository;

  Future<void> call() => _repository.startShift();
}

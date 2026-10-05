import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';

import '../entities/driver_home_entity.dart';
import '../repo/driver_home_repository.dart';

@injectable
class GetDriverHomeUseCase {
  GetDriverHomeUseCase(this._repository);

  final DriverHomeRepository _repository;

  Future<ApiResult<DriverHomeEntity>> call() {
    return _repository.getDriverHome();
  }
}

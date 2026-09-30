import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_profile_entity.dart';
import '../repo/driver_profile_repository.dart';

@injectable
class GetDriverProfileUseCase {
  const GetDriverProfileUseCase(this._repository);

  final DriverProfileRepository _repository;

  Future<ApiResult<DriverProfileEntity>> call() => _repository.getProfile();
}

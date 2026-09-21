import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/driver_nationality_entity.dart';
import '../repo/driver_registration_repository.dart';

@injectable
class GetDriverNationalitiesUseCase {
  const GetDriverNationalitiesUseCase(this._repository);

  final DriverRegistrationRepository _repository;

  Future<ApiResult<List<DriverNationalityEntity>>> call() =>
      _repository.getNationalities();
}

import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/driver_registration_draft_entity.dart';
import '../entities/driver_registration_result_entity.dart';
import '../repo/driver_registration_repository.dart';

@injectable
class SubmitDriverRegistrationUseCase {
  const SubmitDriverRegistrationUseCase(this._repository);

  final DriverRegistrationRepository _repository;

  Future<ApiResult<DriverRegistrationResultEntity>> call(
    DriverRegistrationDraftEntity draft,
  ) =>
      _repository.submitRegistration(draft);
}

import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/driver_registration_result_entity.dart';
import '../entities/driver_resubmit_entity.dart';
import '../repo/driver_registration_repository.dart';

@injectable
class ResubmitDriverRegistrationUseCase {
  const ResubmitDriverRegistrationUseCase(this._repository);

  final DriverRegistrationRepository _repository;

  Future<ApiResult<DriverRegistrationResultEntity>> call({
    required String registrationId,
    required DriverResubmitEntity resubmitData,
  }) => _repository.resubmitRegistration(
    registrationId: registrationId,
    resubmitData: resubmitData,
  );
}

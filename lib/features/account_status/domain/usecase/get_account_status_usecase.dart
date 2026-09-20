import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/driver_registration_status_entity.dart';
import '../repo/account_status_repository.dart';

@injectable
class GetAccountStatusUseCase {
  const GetAccountStatusUseCase(this._repository);

  final AccountStatusRepository _repository;

  Future<ApiResult<DriverRegistrationStatusEntity>> call({
    String? phone,
    String? registrationId,
  }) => _repository.getRegistrationStatus(
    phone: phone,
    registrationId: registrationId,
  );
}

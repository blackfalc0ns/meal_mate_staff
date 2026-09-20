import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/phone_lookup_request_entity.dart';
import '../entities/phone_lookup_result_entity.dart';
import '../repo/auth_repository.dart';

@injectable
class LookupPhoneUseCase {
  const LookupPhoneUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<PhoneLookupResultEntity>> call(
    PhoneLookupRequestEntity request,
  ) {
    return _repository.lookupPhone(request);
  }
}

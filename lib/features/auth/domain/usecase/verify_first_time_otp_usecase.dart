import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/verify_first_time_otp_request_entity.dart';
import '../entities/verify_first_time_otp_result_entity.dart';
import '../repo/auth_repository.dart';

@injectable
class VerifyFirstTimeOtpUseCase {
  const VerifyFirstTimeOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> call(
    VerifyFirstTimeOtpRequestEntity request,
  ) {
    return _repository.verifyFirstTimeOtp(request);
  }
}

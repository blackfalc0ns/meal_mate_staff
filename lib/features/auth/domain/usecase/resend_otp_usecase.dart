import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/resend_otp_request_entity.dart';
import '../repo/auth_repository.dart';

@injectable
class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<String>> call(
    ResendOtpRequestEntity request,
  ) {
    return _repository.resendOtp(request);
  }
}

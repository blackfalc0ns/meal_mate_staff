import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/forgot_password_request_entity.dart';
import '../repo/auth_repository.dart';

@injectable
class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<String>> call(
    ForgotPasswordRequestEntity request,
  ) {
    return _repository.forgotPassword(request);
  }
}

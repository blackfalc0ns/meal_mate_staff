import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/reset_password_request_entity.dart';
import '../repo/auth_repository.dart';

@injectable
class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<String>> call(ResetPasswordRequestEntity request) {
    return _repository.resetPassword(request);
  }
}

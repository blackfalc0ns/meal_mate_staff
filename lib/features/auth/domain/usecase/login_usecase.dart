import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/auth_session_entity.dart';
import '../entities/staff_login_request_entity.dart';
import '../repo/auth_repository.dart';

@injectable
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<AuthSessionEntity>> call(StaffLoginRequestEntity request) {
    return _repository.login(request);
  }
}

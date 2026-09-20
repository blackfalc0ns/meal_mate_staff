import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/auth_session_entity.dart';
import '../entities/set_password_request_entity.dart';
import '../repo/auth_repository.dart';

@injectable
class SetPasswordUseCase {
  const SetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<AuthSessionEntity>> call(SetPasswordRequestEntity request) {
    return _repository.setPassword(request);
  }
}

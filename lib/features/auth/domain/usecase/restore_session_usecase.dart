import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/auth_session_entity.dart';
import '../repo/auth_repository.dart';

@injectable
class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<AuthSessionEntity?>> call() {
    return _repository.restoreSession();
  }
}

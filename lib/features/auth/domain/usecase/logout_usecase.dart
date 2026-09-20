import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../repo/auth_repository.dart';

@injectable
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<void>> call() {
    return _repository.logout();
  }
}

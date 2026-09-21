import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/staff_role_entity.dart';
import '../repo/auth_repository.dart';

@injectable
class GetStaffRolesUseCase {
  const GetStaffRolesUseCase([this._repository]);

  final AuthRepository? _repository;

  Future<ApiResult<List<StaffRoleEntity>>> call() {
    final repo = _repository;
    if (repo == null) {
      return Future.value(ApiSuccessResult(data: const []));
    }
    return repo.getStaffRoles();
  }
}

import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../repo/driver_calling_repository.dart';

@injectable
class RevokeVoiceDeviceUseCase {
  const RevokeVoiceDeviceUseCase(this._repository);

  final DriverCallingRepository _repository;

  Future<ApiResult<void>> call() => _repository.revokeVoiceDevice();
}

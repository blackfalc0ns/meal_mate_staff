import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../repo/driver_calling_repository.dart';

@injectable
class ReportVoiceConnectingUseCase {
  const ReportVoiceConnectingUseCase(this._repository);

  final DriverCallingRepository _repository;

  Future<ApiResult<void>> call(String callId) =>
      _repository.reportConnecting(callId);
}

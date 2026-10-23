import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/voice_call_snapshot_entity.dart';
import '../repo/driver_calling_repository.dart';

@injectable
class InitiateVoiceCallUseCase {
  const InitiateVoiceCallUseCase(this._repository);

  final DriverCallingRepository _repository;

  Future<ApiResult<VoiceCallSnapshotEntity>> call({
    required String tripStopId,
    required String clientRequestId,
  }) =>
      _repository.initiateCall(
        tripStopId: tripStopId,
        clientRequestId: clientRequestId,
      );
}

import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/voice_call_snapshot_entity.dart';
import '../repo/driver_calling_repository.dart';

@injectable
class GetVoiceCallSnapshotUseCase {
  const GetVoiceCallSnapshotUseCase(this._repository);

  final DriverCallingRepository _repository;

  Future<ApiResult<VoiceCallSnapshotEntity>> call(String callId) =>
      _repository.getCallSnapshot(callId);
}

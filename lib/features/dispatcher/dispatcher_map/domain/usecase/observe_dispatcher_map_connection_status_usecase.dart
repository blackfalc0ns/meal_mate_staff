import '../entities/dispatcher_map_connection_status.dart';
import '../repo/dispatcher_map_repository.dart';

class ObserveDispatcherMapConnectionStatusUseCase {
  const ObserveDispatcherMapConnectionStatusUseCase(this._repository);

  final DispatcherMapRepository _repository;

  Stream<DispatcherMapConnectionStatus> call() =>
      _repository.connectionStatuses;
}

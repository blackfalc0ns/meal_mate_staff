import '../repo/dispatcher_map_repository.dart';

class StopDispatcherMapUpdatesUseCase {
  const StopDispatcherMapUpdatesUseCase(this._repository);

  final DispatcherMapRepository _repository;

  Future<void> call() => _repository.stopRealtimeUpdates();
}

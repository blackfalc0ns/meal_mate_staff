import '../repo/dispatcher_map_repository.dart';

class StartDispatcherMapUpdatesUseCase {
  const StartDispatcherMapUpdatesUseCase(this._repository);

  final DispatcherMapRepository _repository;

  Future<void> call() => _repository.startRealtimeUpdates();
}

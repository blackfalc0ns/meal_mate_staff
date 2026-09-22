import '../entities/dispatcher_map_realtime_event.dart';
import '../repo/dispatcher_map_repository.dart';

class ObserveDispatcherMapUpdatesUseCase {
  const ObserveDispatcherMapUpdatesUseCase(this._repository);

  final DispatcherMapRepository _repository;

  Stream<DispatcherMapRealtimeEvent> call() => _repository.realtimeEvents;
}

import 'package:injectable/injectable.dart';

import '../../../dispatcher_map/domain/entities/dispatcher_map_connection_status.dart';
import '../../../dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart';
import '../../../dispatcher_map/domain/repo/dispatcher_map_repository.dart';

@injectable
class ObserveDriverDetailsUpdatesUseCase {
  const ObserveDriverDetailsUpdatesUseCase(this._mapRepository);

  final DispatcherMapRepository _mapRepository;

  Stream<DispatcherMapRealtimeEvent> get events =>
      _mapRepository.realtimeEvents;

  Stream<DispatcherMapConnectionStatus> get connectionStatuses =>
      _mapRepository.connectionStatuses;
}

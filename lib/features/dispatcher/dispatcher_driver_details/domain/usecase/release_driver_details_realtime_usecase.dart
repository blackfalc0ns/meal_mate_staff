import 'package:injectable/injectable.dart';

import '../../../dispatcher_map/data/realtime/dispatcher_map_realtime_client.dart';

@injectable
class ReleaseDriverDetailsRealtimeUseCase {
  const ReleaseDriverDetailsRealtimeUseCase(this._realtimeClient);

  final DispatcherMapRealtimeClient _realtimeClient;

  Future<void> call(String driverId) {
    return _realtimeClient.release('driver-details:$driverId');
  }
}

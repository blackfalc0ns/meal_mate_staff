import 'package:injectable/injectable.dart';

import '../../../dispatcher_map/data/realtime/dispatcher_map_realtime_client.dart';

@injectable
class AcquireDriverDetailsRealtimeUseCase {
  const AcquireDriverDetailsRealtimeUseCase(this._realtimeClient);

  final DispatcherMapRealtimeClient _realtimeClient;

  Future<void> call(String driverId) {
    return _realtimeClient.acquire('driver-details:$driverId');
  }
}

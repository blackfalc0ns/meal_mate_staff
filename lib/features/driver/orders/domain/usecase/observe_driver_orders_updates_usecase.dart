import 'package:injectable/injectable.dart';

import '../../data/realtime/driver_orders_realtime_client.dart';
import '../entities/driver_orders_realtime_event.dart';

@injectable
class ObserveDriverOrdersUpdatesUseCase {
  const ObserveDriverOrdersUpdatesUseCase(this._client);

  final DriverOrdersRealtimeClient _client;

  Stream<DriverOrdersRealtimeEvent> call() => _client.events;
}

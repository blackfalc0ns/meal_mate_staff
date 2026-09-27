import 'package:injectable/injectable.dart';

import '../../data/realtime/driver_orders_realtime_client.dart';

@injectable
class StartDriverOrdersUpdatesUseCase {
  const StartDriverOrdersUpdatesUseCase(this._client);

  final DriverOrdersRealtimeClient _client;

  Future<void> call() => _client.start();
}

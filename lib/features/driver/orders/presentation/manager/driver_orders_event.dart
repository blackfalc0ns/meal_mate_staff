import '../../domain/entities/driver_orders_filter.dart';
import '../../domain/entities/driver_orders_realtime_event.dart';

sealed class DriverOrdersEvent {
  const DriverOrdersEvent();
}

class LoadDriverOrdersEvent extends DriverOrdersEvent {
  const LoadDriverOrdersEvent();
}

class RefreshDriverOrdersEvent extends DriverOrdersEvent {
  const RefreshDriverOrdersEvent();
}

class SearchDriverOrdersEvent extends DriverOrdersEvent {
  const SearchDriverOrdersEvent(this.query);

  final String query;
}

class SelectDriverOrdersFilterEvent extends DriverOrdersEvent {
  const SelectDriverOrdersFilterEvent(this.filter);

  final DriverOrdersFilter filter;
}

class ResetDriverOrdersQueryEvent extends DriverOrdersEvent {
  const ResetDriverOrdersQueryEvent();
}

class StartDriverOrdersRealtimeEvent extends DriverOrdersEvent {
  const StartDriverOrdersRealtimeEvent();
}

class StopDriverOrdersRealtimeEvent extends DriverOrdersEvent {
  const StopDriverOrdersRealtimeEvent();
}

class DriverOrdersRealtimeReceivedEvent extends DriverOrdersEvent {
  const DriverOrdersRealtimeReceivedEvent(this.event);

  final DriverOrdersRealtimeEvent event;
}

class DriverOrdersRealtimeStatusChangedEvent extends DriverOrdersEvent {
  const DriverOrdersRealtimeStatusChangedEvent(this.isConnected);

  final bool isConnected;
}

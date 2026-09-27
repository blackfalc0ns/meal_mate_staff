import '../../domain/entities/dispatcher_driver_status_type.dart';

sealed class DispatcherDriversStatusEvent {
  const DispatcherDriversStatusEvent();
}

final class LoadDispatcherDriversStatusEvent extends DispatcherDriversStatusEvent {
  const LoadDispatcherDriversStatusEvent();
}

final class RefreshDispatcherDriversStatusEvent extends DispatcherDriversStatusEvent {
  const RefreshDispatcherDriversStatusEvent();
}

final class SearchDriversStatusEvent extends DispatcherDriversStatusEvent {
  const SearchDriversStatusEvent(this.query);
  final String query;
}

final class FilterDriversStatusEvent extends DispatcherDriversStatusEvent {
  const FilterDriversStatusEvent(this.statusFilter);
  final DispatcherDriverStatusType? statusFilter;
}

final class ToggleDriverStatusEvent extends DispatcherDriversStatusEvent {
  const ToggleDriverStatusEvent(this.driverId, this.isAvailable);
  final String driverId;
  final bool isAvailable;
}

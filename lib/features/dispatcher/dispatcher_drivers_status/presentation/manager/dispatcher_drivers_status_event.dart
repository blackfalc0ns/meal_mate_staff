import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../../domain/entities/dispatcher_drivers_status_sort.dart';
import '../../domain/entities/update_driver_availability_result_entity.dart';

sealed class DispatcherDriversStatusEvent {
  const DispatcherDriversStatusEvent();
}

final class LoadDispatcherDriversStatusEvent
    extends DispatcherDriversStatusEvent {
  const LoadDispatcherDriversStatusEvent();
}

final class RefreshDispatcherDriversStatusEvent
    extends DispatcherDriversStatusEvent {
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

final class SortDriversStatusEvent extends DispatcherDriversStatusEvent {
  const SortDriversStatusEvent(this.sort);
  final DispatcherDriversStatusSort sort;
}

final class ChangeDriversStatusPageEvent extends DispatcherDriversStatusEvent {
  const ChangeDriversStatusPageEvent(this.pageNumber);
  final int pageNumber;
}

final class ToggleDriverStatusEvent extends DispatcherDriversStatusEvent {
  const ToggleDriverStatusEvent(this.driverId, this.isAvailable, {this.reason});

  final String driverId;
  final bool isAvailable;
  final String? reason;
}

final class DriverAvailabilityUpdatedRealtimeEvent
    extends DispatcherDriversStatusEvent {
  const DriverAvailabilityUpdatedRealtimeEvent(this.update);
  final UpdateDriverAvailabilityResultEntity update;
}

final class ClearActionFailureEvent extends DispatcherDriversStatusEvent {
  const ClearActionFailureEvent();
}

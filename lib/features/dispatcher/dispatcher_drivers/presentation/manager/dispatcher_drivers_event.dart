import '../../domain/entities/dispatcher_driver_entity.dart';
import '../../domain/entities/dispatcher_driver_sort.dart';
import '../../domain/entities/dispatcher_driver_view_mode.dart';

sealed class DispatcherDriversEvent {
  const DispatcherDriversEvent();
}

class LoadDispatcherDriversEvent extends DispatcherDriversEvent {
  const LoadDispatcherDriversEvent();
}

class RetryDispatcherDriversEvent extends DispatcherDriversEvent {
  const RetryDispatcherDriversEvent();
}

class RefreshDispatcherDriversEvent extends DispatcherDriversEvent {
  const RefreshDispatcherDriversEvent();
}

class ChangeDispatcherDriversViewEvent extends DispatcherDriversEvent {
  const ChangeDispatcherDriversViewEvent(this.view);
  final DispatcherDriverViewMode view;
}

class ChangeDispatcherDriversAreaEvent extends DispatcherDriversEvent {
  const ChangeDispatcherDriversAreaEvent(this.areaKey, [this.areaName]);
  final String areaKey;
  final String? areaName;
}

class ChangeDispatcherDriversSortEvent extends DispatcherDriversEvent {
  const ChangeDispatcherDriversSortEvent(this.sort);
  final DispatcherDriverSort sort;
}

class SelectRosterDriverEvent extends DispatcherDriversEvent {
  const SelectRosterDriverEvent(this.driver);
  final DispatcherDriverEntity driver;
}

class AssignRosterDriverEvent extends DispatcherDriversEvent {
  const AssignRosterDriverEvent(this.driver);
  final DispatcherDriverEntity driver;
}

class ClearDispatcherDriversNoticeEvent extends DispatcherDriversEvent {
  const ClearDispatcherDriversNoticeEvent();
}

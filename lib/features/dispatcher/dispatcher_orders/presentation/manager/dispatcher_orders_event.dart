import '../../domain/entities/dispatcher_filter_type.dart';

sealed class DispatcherOrdersEvent {
  const DispatcherOrdersEvent();
}

class LoadDispatcherOrdersEvent extends DispatcherOrdersEvent {
  const LoadDispatcherOrdersEvent();
}

class RefreshDispatcherOrdersEvent extends DispatcherOrdersEvent {
  const RefreshDispatcherOrdersEvent();
}

class SelectDispatcherFilterEvent extends DispatcherOrdersEvent {
  const SelectDispatcherFilterEvent(this.filter);

  final DispatcherFilterType filter;
}

class RetryDispatcherOrdersEvent extends DispatcherOrdersEvent {
  const RetryDispatcherOrdersEvent();
}

import '../../domain/entities/dispatcher_support_date_preset.dart';
import '../../domain/entities/dispatcher_support_status.dart';

sealed class DispatcherSupportEvent {
  const DispatcherSupportEvent();
}

class LoadDispatcherSupportEvent extends DispatcherSupportEvent {
  const LoadDispatcherSupportEvent();
}

class RetryDispatcherSupportEvent extends DispatcherSupportEvent {
  const RetryDispatcherSupportEvent();
}

class ChangeDispatcherSupportStatusEvent extends DispatcherSupportEvent {
  const ChangeDispatcherSupportStatusEvent(this.status);

  final DispatcherSupportStatus status;
}

class ChangeDispatcherSupportAreaEvent extends DispatcherSupportEvent {
  const ChangeDispatcherSupportAreaEvent(this.area);

  final String? area;
}

class ChangeDispatcherSupportDatePresetEvent extends DispatcherSupportEvent {
  const ChangeDispatcherSupportDatePresetEvent(this.datePreset);

  final DispatcherSupportDatePreset datePreset;
}

class ChangeDispatcherSupportCustomDateRangeEvent
    extends DispatcherSupportEvent {
  const ChangeDispatcherSupportCustomDateRangeEvent({
    required this.fromDateUtc,
    required this.toDateUtc,
  });

  final DateTime fromDateUtc;
  final DateTime toDateUtc;
}

class ChangeDispatcherSupportSearchEvent extends DispatcherSupportEvent {
  const ChangeDispatcherSupportSearchEvent(this.search);

  final String search;
}

class ClearDispatcherSupportSearchEvent extends DispatcherSupportEvent {
  const ClearDispatcherSupportSearchEvent();
}

class LoadNextDispatcherSupportPageEvent extends DispatcherSupportEvent {
  const LoadNextDispatcherSupportPageEvent();
}

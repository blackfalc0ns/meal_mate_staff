import '../../domain/entities/operation_status.dart';
import '../../domain/entities/operations_date_preset.dart';

sealed class OperationsEvent {
  const OperationsEvent();
}

class LoadOperationsEvent extends OperationsEvent {
  const LoadOperationsEvent();
}

class RetryOperationsEvent extends OperationsEvent {
  const RetryOperationsEvent();
}

class RefreshOperationsEvent extends OperationsEvent {
  const RefreshOperationsEvent();
}

class ChangeOperationsStatusEvent extends OperationsEvent {
  const ChangeOperationsStatusEvent(this.status);
  final OperationStatus status;
}

class ChangeOperationsSearchEvent extends OperationsEvent {
  const ChangeOperationsSearchEvent(this.search);
  final String search;
}

class ClearOperationsSearchEvent extends OperationsEvent {
  const ClearOperationsSearchEvent();
}

class ChangeOperationsDatePresetEvent extends OperationsEvent {
  const ChangeOperationsDatePresetEvent(this.preset);
  final OperationsDatePreset preset;
}

class ChangeOperationsCustomDateRangeEvent extends OperationsEvent {
  const ChangeOperationsCustomDateRangeEvent({
    required this.fromDateUtc,
    required this.toDateUtc,
  });

  final DateTime fromDateUtc;
  final DateTime toDateUtc;
}

class GoToPreviousOperationsPageEvent extends OperationsEvent {
  const GoToPreviousOperationsPageEvent();
}

class GoToNextOperationsPageEvent extends OperationsEvent {
  const GoToNextOperationsPageEvent();
}

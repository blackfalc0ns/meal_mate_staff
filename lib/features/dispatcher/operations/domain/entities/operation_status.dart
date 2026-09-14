enum OperationStatus {
  completed,
  reassigned,
  failed,
  cancelled;

  bool get isCompleted => this == OperationStatus.completed;
  bool get isReassigned => this == OperationStatus.reassigned;
  bool get isFailed => this == OperationStatus.failed;
  bool get isCancelled => this == OperationStatus.cancelled;
}

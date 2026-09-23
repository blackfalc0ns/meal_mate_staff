enum OperationStatus {
  all,
  completed,
  cancelled,
  failed,
  reassigned,
  unknown;

  bool get isCompleted => this == OperationStatus.completed;
  bool get isReassigned => this == OperationStatus.reassigned;
  bool get isFailed => this == OperationStatus.failed;
  bool get isCancelled => this == OperationStatus.cancelled;
  bool get isAll => this == OperationStatus.all;
  bool get isUnknown => this == OperationStatus.unknown;

  String get apiValue {
    switch (this) {
      case OperationStatus.all:
        return 'All';
      case OperationStatus.completed:
        return 'Completed';
      case OperationStatus.cancelled:
        return 'Cancelled';
      case OperationStatus.failed:
        return 'Failed';
      case OperationStatus.reassigned:
        return 'Reassigned';
      case OperationStatus.unknown:
        return 'Unknown';
    }
  }
}

extension OperationStatusX on OperationStatus {
  static OperationStatus fromApi(String? value) {
    if (value == null) return OperationStatus.unknown;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'all':
        return OperationStatus.all;
      case 'completed':
        return OperationStatus.completed;
      case 'cancelled':
      case 'cancelledbyrestaurant':
      case 'cancelled_by_restaurant':
      case 'cancelled_by_user':
      case 'cancelledbycustomer':
        return OperationStatus.cancelled;
      case 'failed':
        return OperationStatus.failed;
      case 'reassigned':
        return OperationStatus.reassigned;
      default:
        return OperationStatus.unknown;
    }
  }
}

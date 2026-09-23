enum OperationsDatePreset {
  today,
  last7Days,
  last30Days,
  custom,
  all;

  String get apiValue {
    switch (this) {
      case OperationsDatePreset.today:
        return 'Today';
      case OperationsDatePreset.last7Days:
        return 'Last7Days';
      case OperationsDatePreset.last30Days:
        return 'Last30Days';
      case OperationsDatePreset.custom:
        return 'Custom';
      case OperationsDatePreset.all:
        return 'All';
    }
  }
}

extension OperationsDatePresetX on OperationsDatePreset {
  static OperationsDatePreset fromApi(String? value) {
    if (value == null) return OperationsDatePreset.last7Days;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'today':
        return OperationsDatePreset.today;
      case 'last7days':
      case 'last_7_days':
        return OperationsDatePreset.last7Days;
      case 'last30days':
      case 'last_30_days':
        return OperationsDatePreset.last30Days;
      case 'custom':
        return OperationsDatePreset.custom;
      case 'all':
        return OperationsDatePreset.all;
      default:
        return OperationsDatePreset.last7Days;
    }
  }
}

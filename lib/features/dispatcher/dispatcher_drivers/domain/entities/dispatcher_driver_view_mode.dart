enum DispatcherDriverViewMode {
  byArea,
  allDrivers;

  String get apiValue {
    switch (this) {
      case DispatcherDriverViewMode.byArea:
        return 'ByArea';
      case DispatcherDriverViewMode.allDrivers:
        return 'All';
    }
  }
}

extension DispatcherDriverViewModeX on DispatcherDriverViewMode {
  static DispatcherDriverViewMode fromApi(String? value) {
    if (value == null) return DispatcherDriverViewMode.byArea;
    switch (value.trim()) {
      case 'All':
        return DispatcherDriverViewMode.allDrivers;
      case 'ByArea':
      default:
        return DispatcherDriverViewMode.byArea;
    }
  }
}

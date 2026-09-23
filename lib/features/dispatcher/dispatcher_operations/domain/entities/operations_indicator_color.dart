enum OperationsIndicatorColor { green, orange, red, grey, unknown }

extension OperationsIndicatorColorX on OperationsIndicatorColor {
  static OperationsIndicatorColor fromApi(String? value) {
    if (value == null) return OperationsIndicatorColor.unknown;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'green':
        return OperationsIndicatorColor.green;
      case 'orange':
        return OperationsIndicatorColor.orange;
      case 'red':
        return OperationsIndicatorColor.red;
      case 'grey':
      case 'gray':
        return OperationsIndicatorColor.grey;
      default:
        return OperationsIndicatorColor.unknown;
    }
  }
}

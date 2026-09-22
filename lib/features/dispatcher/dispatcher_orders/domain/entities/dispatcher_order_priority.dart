enum DispatcherOrderPriority {
  newOrder,
  urgent,
  highPriority,
  normal,
  unknown;

  static DispatcherOrderPriority fromWire(String? value) {
    return switch (value?.toLowerCase()) {
      'new' => DispatcherOrderPriority.newOrder,
      'urgent' => DispatcherOrderPriority.urgent,
      'highpriority' => DispatcherOrderPriority.highPriority,
      'normal' => DispatcherOrderPriority.normal,
      _ => DispatcherOrderPriority.unknown,
    };
  }
}

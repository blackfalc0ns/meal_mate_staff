enum DispatcherOrderStatus {
  pending,
  assigned,
  inDelivery,
  issue,
  unknown;

  static DispatcherOrderStatus fromWire(String? value) {
    return switch (value?.toLowerCase()) {
      'pending' => DispatcherOrderStatus.pending,
      'assigned' => DispatcherOrderStatus.assigned,
      'indelivery' => DispatcherOrderStatus.inDelivery,
      'issue' => DispatcherOrderStatus.issue,
      _ => DispatcherOrderStatus.unknown,
    };
  }
}

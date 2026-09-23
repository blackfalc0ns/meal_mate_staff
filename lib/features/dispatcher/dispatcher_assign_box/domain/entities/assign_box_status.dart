enum AssignBoxStatus {
  pending,
  assigned,
  inDelivery,
  issue,
  delivered,
  cancelled,
  unknown,
}

extension AssignBoxStatusX on AssignBoxStatus {
  static AssignBoxStatus fromApi(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'pending' => AssignBoxStatus.pending,
      'assigned' => AssignBoxStatus.assigned,
      'indelivery' => AssignBoxStatus.inDelivery,
      'issue' => AssignBoxStatus.issue,
      'delivered' => AssignBoxStatus.delivered,
      'cancelled' => AssignBoxStatus.cancelled,
      _ => AssignBoxStatus.unknown,
    };
  }
}

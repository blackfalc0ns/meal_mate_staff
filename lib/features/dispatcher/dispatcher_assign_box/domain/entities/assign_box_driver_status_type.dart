enum AssignBoxDriverStatusType {
  available,
  busy,
  inDelivery,
  returning,
  unknown,
}

extension AssignBoxDriverStatusTypeX on AssignBoxDriverStatusType {
  static AssignBoxDriverStatusType fromApi(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'available' => AssignBoxDriverStatusType.available,
      'busy' => AssignBoxDriverStatusType.busy,
      'indelivery' => AssignBoxDriverStatusType.inDelivery,
      'returning' => AssignBoxDriverStatusType.returning,
      _ => AssignBoxDriverStatusType.unknown,
    };
  }
}

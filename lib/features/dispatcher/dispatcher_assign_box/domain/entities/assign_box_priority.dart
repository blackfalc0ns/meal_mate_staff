enum AssignBoxPriority {
  normal,
  high,
  urgent,
  low,
  unknown,
}

extension AssignBoxPriorityX on AssignBoxPriority {
  static AssignBoxPriority fromApi(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'normal' => AssignBoxPriority.normal,
      'high' || 'highpriority' => AssignBoxPriority.high,
      'urgent' => AssignBoxPriority.urgent,
      'low' => AssignBoxPriority.low,
      _ => AssignBoxPriority.unknown,
    };
  }
}

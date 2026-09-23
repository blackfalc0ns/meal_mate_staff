enum BoxTrackingStepIconKind { restaurant, driver, truck, receipt, unknown }

extension BoxTrackingStepIconKindX on BoxTrackingStepIconKind {
  static BoxTrackingStepIconKind fromApi(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'restaurant' => BoxTrackingStepIconKind.restaurant,
      'driver' => BoxTrackingStepIconKind.driver,
      'truck' => BoxTrackingStepIconKind.truck,
      'receipt' => BoxTrackingStepIconKind.receipt,
      _ => BoxTrackingStepIconKind.unknown,
    };
  }
}

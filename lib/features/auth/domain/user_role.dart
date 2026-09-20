enum UserRole {
  driver,
  operations;

  static const String driverApiValue = 'Driver';
  static const String deliveryManagerApiValue = 'DeliveryManager';

  String get apiValue {
    switch (this) {
      case UserRole.driver:
        return driverApiValue;
      case UserRole.operations:
        return deliveryManagerApiValue;
    }
  }

  static UserRole fromApiValue(String? value) {
    if (value == null) return UserRole.operations;
    final normalized = value.trim().toLowerCase();
    if (normalized == 'driver') {
      return UserRole.driver;
    }
    return UserRole.operations;
  }
}

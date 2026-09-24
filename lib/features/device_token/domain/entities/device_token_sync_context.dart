sealed class DeviceTokenSyncContext {
  const DeviceTokenSyncContext();

  const factory DeviceTokenSyncContext.driverPreLogin({
    required String registrationId,
  }) = DriverPreLoginSyncContext;

  const factory DeviceTokenSyncContext.driverAuthenticated({
    required String userId,
  }) = DriverAuthenticatedSyncContext;

  const factory DeviceTokenSyncContext.deliveryManagerAuthenticated({
    required String userId,
  }) = DeliveryManagerAuthenticatedSyncContext;
}

class DriverPreLoginSyncContext extends DeviceTokenSyncContext {
  const DriverPreLoginSyncContext({required this.registrationId});

  final String registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverPreLoginSyncContext &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverAuthenticatedSyncContext extends DeviceTokenSyncContext {
  const DriverAuthenticatedSyncContext({required this.userId});

  final String userId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverAuthenticatedSyncContext &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

class DeliveryManagerAuthenticatedSyncContext extends DeviceTokenSyncContext {
  const DeliveryManagerAuthenticatedSyncContext({required this.userId});

  final String userId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryManagerAuthenticatedSyncContext &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

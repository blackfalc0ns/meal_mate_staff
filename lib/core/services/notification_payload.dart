sealed class PushNotificationPayload {
  const PushNotificationPayload();
}

class DriverRegistrationRestaurantApprovedPayload
    extends PushNotificationPayload {
  const DriverRegistrationRestaurantApprovedPayload({
    required this.registrationId,
  });

  final String registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRegistrationRestaurantApprovedPayload &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverRegistrationChangesRequestedPayload
    extends PushNotificationPayload {
  const DriverRegistrationChangesRequestedPayload({
    required this.registrationId,
  });

  final String registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRegistrationChangesRequestedPayload &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverRegistrationRestaurantRejectedPayload
    extends PushNotificationPayload {
  const DriverRegistrationRestaurantRejectedPayload({
    required this.registrationId,
  });

  final String registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRegistrationRestaurantRejectedPayload &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverRegistrationAdminConfirmedPayload extends PushNotificationPayload {
  const DriverRegistrationAdminConfirmedPayload({required this.registrationId});

  final String registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRegistrationAdminConfirmedPayload &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverRegistrationAdminApprovedPayload extends PushNotificationPayload {
  const DriverRegistrationAdminApprovedPayload({required this.registrationId});

  final String registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRegistrationAdminApprovedPayload &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverRegistrationAdminChangesRequestedPayload
    extends PushNotificationPayload {
  const DriverRegistrationAdminChangesRequestedPayload({
    required this.registrationId,
  });

  final String registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRegistrationAdminChangesRequestedPayload &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverRegistrationAdminRejectedPayload extends PushNotificationPayload {
  const DriverRegistrationAdminRejectedPayload({required this.registrationId});

  final String registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRegistrationAdminRejectedPayload &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverRegistrationSubmittedPayload extends PushNotificationPayload {
  const DriverRegistrationSubmittedPayload({required this.registrationId});

  final String registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRegistrationSubmittedPayload &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverRegistrationIndependentSubmittedPayload
    extends PushNotificationPayload {
  const DriverRegistrationIndependentSubmittedPayload({
    required this.registrationId,
  });

  final String registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRegistrationIndependentSubmittedPayload &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverRegistrationResubmittedPayload extends PushNotificationPayload {
  const DriverRegistrationResubmittedPayload({required this.registrationId});

  final String registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRegistrationResubmittedPayload &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverRegistrationStatusDeepLinkPayload
    extends PushNotificationPayload {
  const DriverRegistrationStatusDeepLinkPayload({this.registrationId});

  final String? registrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRegistrationStatusDeepLinkPayload &&
          runtimeType == other.runtimeType &&
          registrationId == other.registrationId;

  @override
  int get hashCode => registrationId.hashCode;
}

class DriverBoxAssignedPayload extends PushNotificationPayload {
  const DriverBoxAssignedPayload({required this.boxId});

  final String boxId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverBoxAssignedPayload &&
          runtimeType == other.runtimeType &&
          boxId == other.boxId;

  @override
  int get hashCode => boxId.hashCode;
}

class DriverTripAssignedPayload extends PushNotificationPayload {
  const DriverTripAssignedPayload({required this.tripId});

  final String tripId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverTripAssignedPayload &&
          runtimeType == other.runtimeType &&
          tripId == other.tripId;

  @override
  int get hashCode => tripId.hashCode;
}

class DriverTripKitchenReadyPayload extends PushNotificationPayload {
  const DriverTripKitchenReadyPayload({required this.tripId});

  final String tripId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverTripKitchenReadyPayload &&
          runtimeType == other.runtimeType &&
          tripId == other.tripId;

  @override
  int get hashCode => tripId.hashCode;
}

class DispatcherBatchReadyPayload extends PushNotificationPayload {
  const DispatcherBatchReadyPayload({required this.batchId});

  final String batchId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherBatchReadyPayload &&
          runtimeType == other.runtimeType &&
          batchId == other.batchId;

  @override
  int get hashCode => batchId.hashCode;
}

class IncomingCallPayload extends PushNotificationPayload {
  const IncomingCallPayload({required this.rawData});

  final Map<String, dynamic> rawData;
}

class UnsupportedNotificationPayload extends PushNotificationPayload {
  const UnsupportedNotificationPayload({
    required this.rawData,
    required this.reason,
  });

  final Map<String, dynamic> rawData;
  final String reason;
}

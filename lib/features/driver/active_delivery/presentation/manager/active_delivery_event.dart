sealed class ActiveDeliveryEvent {
  const ActiveDeliveryEvent();
}

class LoadActiveDeliveryEvent extends ActiveDeliveryEvent {
  const LoadActiveDeliveryEvent({this.stopId, this.tripId});
  final String? stopId;
  final String? tripId;
}

class RefreshActiveDeliveryEvent extends ActiveDeliveryEvent {
  const RefreshActiveDeliveryEvent();
}

class StartActiveDeliveryRouteEvent extends ActiveDeliveryEvent {
  const StartActiveDeliveryRouteEvent();
}

class ConfirmCustomerArrivalEvent extends ActiveDeliveryEvent {
  const ConfirmCustomerArrivalEvent({this.latitude, this.longitude});
  final double? latitude;
  final double? longitude;
}

class DeliveryProofSelectedEvent extends ActiveDeliveryEvent {
  const DeliveryProofSelectedEvent(this.localPath);
  final String localPath;
}

class RetryDeliveryProofUploadEvent extends ActiveDeliveryEvent {
  const RetryDeliveryProofUploadEvent();
}

class OptionalDeliveryOtpChangedEvent extends ActiveDeliveryEvent {
  const OptionalDeliveryOtpChangedEvent(this.value);
  final String value;
}

class ConfirmCustomerDeliveryEvent extends ActiveDeliveryEvent {
  const ConfirmCustomerDeliveryEvent({this.latitude, this.longitude});
  final double? latitude;
  final double? longitude;
}

class ReconcileActiveDeliveryEvent extends ActiveDeliveryEvent {
  const ReconcileActiveDeliveryEvent();
}

class ClearActiveDeliveryNavigationEvent extends ActiveDeliveryEvent {
  const ClearActiveDeliveryNavigationEvent();
}

class ActiveDeliveryPausedEvent extends ActiveDeliveryEvent {
  const ActiveDeliveryPausedEvent();
}

class ActiveDeliveryResumedEvent extends ActiveDeliveryEvent {
  const ActiveDeliveryResumedEvent();
}

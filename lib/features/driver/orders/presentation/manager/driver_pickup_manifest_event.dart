import '../../domain/entities/driver_boxes_filter_type.dart';

sealed class DriverPickupManifestEvent {
  const DriverPickupManifestEvent();
}

class LoadDriverPickupManifestEvent extends DriverPickupManifestEvent {
  const LoadDriverPickupManifestEvent();
}

class RefreshDriverPickupManifestEvent extends DriverPickupManifestEvent {
  const RefreshDriverPickupManifestEvent();
}

class SelectDriverBoxesFilterEvent extends DriverPickupManifestEvent {
  const SelectDriverBoxesFilterEvent(this.filter);

  final DriverBoxesFilterType filter;
}

class RetryDriverPickupManifestEvent extends DriverPickupManifestEvent {
  const RetryDriverPickupManifestEvent();
}

sealed class DriverPickupFlowEvent {
  const DriverPickupFlowEvent();
}

class ValidateBarcodeEvent extends DriverPickupFlowEvent {
  const ValidateBarcodeEvent(this.barcodeValue);
  final String barcodeValue;
}

class StepChangedEvent extends DriverPickupFlowEvent {
  const StepChangedEvent(this.step);
  final int step;
}

class PhotoSelectedEvent extends DriverPickupFlowEvent {
  const PhotoSelectedEvent(this.photoPath);
  final String photoPath;
}

class UploadPhotoEvent extends DriverPickupFlowEvent {
  const UploadPhotoEvent();
}

class ConfirmPickupEvent extends DriverPickupFlowEvent {
  const ConfirmPickupEvent();
}

class RetryFailedStageEvent extends DriverPickupFlowEvent {
  const RetryFailedStageEvent();
}

class ResetScanEvent extends DriverPickupFlowEvent {
  const ResetScanEvent();
}
